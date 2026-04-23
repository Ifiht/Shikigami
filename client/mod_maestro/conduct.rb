# conduct.rb — Maestro Orchestrator
#
# Persistent daemon that forms the connective tissue of the Shikigami voice pipeline:
#
#   whisper (FIFO/stdin) -> maestro -> llama-server (HTTP/SSE) -> beanstalkd tts tube -> hamelin
#
# Design principles:
#   - Single main thread; blocking I/O on the whisper pipe is intentional and correct.
#   - All beanstalkd I/O goes through Spriggan. TTS jobs use send_msg_cleartxt because
#     hamelin (piper-serve.cpp) reads raw UTF-8 job bodies directly — it is not a Ruby
#     process and cannot decode Spriggan's YAML/Base64 envelope format.
#   - The LLM is streamed via SSE and sentences are flushed to beanstalkd as they complete,
#     so TTS begins on the first sentence while the model is still generating the rest.
#     This is the primary perceived-latency optimization in the pipeline.
#   - All config is via environment variables for consistency with how hamelin is invoked.
#   - PM2 manages process lifecycle; this daemon does not daemonize itself.
#
# TODO: Replace in-process history with server-side history retrieval — the server
#       will own an SQLite3 db of all conversations across all clients; maestro should
#       send a client ID and receive context back rather than maintaining its own state.
# TODO: SWI-Prolog world model verification is a server responsibility; no client work needed here.
# TODO: Add tool-call parsing when agentic workflows are needed (jinja template already supports it)
# TODO: Wake-word / VAD gating upstream of this process (currently assumes whisper handles it)

require "bundler/setup"
require "faraday"
require "faraday/net_http"
require "json"
# Spriggan provides beanstalkd client helpers, PM2-aware logging, and port pre-flight
# checks. Sourced from GitHub via the Gemfile (Ifiht/Spriggan).
require "spriggan"

# --- Configuration (environment variables) ------------------------------------
# Defaults assume all processes are co-located on the client machine.
# Set LLAMA_HOST to the production server's address when running distributed.
LLAMA_HOST      = ENV.fetch("LLAMA_HOST",    "localhost")
LLAMA_PORT      = ENV.fetch("LLAMA_PORT",    "8080")
BEANSTALK_HOST  = ENV.fetch("BEANSTALK_HOST", "localhost")
BEANSTALK_PORT  = ENV.fetch("BEANSTALK_PORT", "11300").to_i
TTS_TUBE        = ENV.fetch("TTS_TUBE",      "tts")        # must match tube hamelin watches
WHISPER_PIPE    = ENV.fetch("WHISPER_PIPE",  "/dev/stdin") # path to named FIFO or /dev/stdin
MAX_HISTORY     = ENV.fetch("MAX_HISTORY",   "20").to_i    # max user+assistant turn pairs retained

# System prompt injected as the first message in every conversation.
# Mirrors the default_system_message in server/mod_llama/template.example.jinja.
# TODO: Read this from a shared config or the jinja template directly to avoid drift.
SYSTEM_PROMPT = "Your name is Shikigami. You are a succinct and to-the-point personal assistant running in a 28672 token context window."

LLAMA_URL = "http://#{LLAMA_HOST}:#{LLAMA_PORT}"

# Regex to detect sentence boundaries for mid-stream TTS flushing.
# Triggers on punctuation followed by whitespace or newline.
# Intentionally simple — no NLP library — sufficient for conversational output.
# TODO: Consider flushing on list/markdown boundaries (e.g. newline-prefixed `-`) for
#       responses that use structured formatting.
SENTENCE_BOUNDARY = /[.?!][\s\n]/

# Blocks until beanstalkd is reachable, then returns a connected Spriggan instance.
# Uses Spriggan's port_open? (check_conn.rb) for a lightweight TCP pre-flight check
# before attempting the full Beaneater handshake, avoiding noisy connection exceptions
# during startup races with beanstalkd.
def connect_spriggan
  loop do
    if port_open?(BEANSTALK_HOST, BEANSTALK_PORT)
      sg = Spriggan.new(
        beanstalk_host: BEANSTALK_HOST,
        beanstalk_port: BEANSTALK_PORT,
        module_name: "maestro"
      )
      sg.pm2_log "[maestro] Connected to beanstalkd at #{BEANSTALK_HOST}:#{BEANSTALK_PORT}"
      return sg
    else
      $stderr.puts "[maestro] Beanstalkd unreachable, retrying in 5s..."
      sleep 5
    end
  end
end

def connect_llama
  Faraday.new(url: LLAMA_URL) do |f|
    f.adapter :net_http
  end
end

# Trims the in-process conversation history to MAX_HISTORY turn pairs (user + assistant),
# dropping the oldest pairs first. The system message is always preserved at index 0.
# Turn-count capping is used rather than token counting — approximate but safe given
# typical conversational turn lengths vs. the 28672-token context window.
# NOTE: This entire mechanism is temporary. Once the server owns a multi-client SQLite3
# conversation store, maestro will send a client ID and receive context from the server
# instead of maintaining its own history.
def trim_history(history)
  system_msg = history.first[:role] == "system" ? [history.shift] : []
  while history.length > MAX_HISTORY * 2
    history.shift(2)
  end
  system_msg + history
end

# Submits a completed sentence to the beanstalkd TTS tube as a plain-text job.
# send_msg_cleartxt is used deliberately here — hamelin (piper-serve.cpp) reads
# job->data directly as a C string and passes it to piper_synthesize_start.
# Spriggan's standard send_msg wraps payloads in YAML+Base64, which would cause
# hamelin to attempt to synthesize the encoded envelope instead of the text.
def flush_sentence(sg, buffer)
  sentence = buffer.strip
  return if sentence.empty?
  sg.pm2_log "[maestro] TTS -> #{sentence.inspect}"
  begin
    sg.send_msg_cleartxt(sentence, TTS_TUBE)
  rescue => e
    $stderr.puts "[maestro] Beanstalkd put failed (#{e.message})"
    raise
  end
end

# Streams a chat completion from llama-server and flushes sentences to beanstalkd
# as they complete. Returns the full assembled response string.
#
# Streaming design:
#   - on_data callback fires as HTTP chunks arrive from the SSE stream.
#   - Each chunk may contain multiple SSE lines; we split on newlines and process each.
#   - Tokens are appended to both `buffer` (pending sentence) and `full_resp` (full reply).
#   - When SENTENCE_BOUNDARY matches in the buffer, all complete sentences are flushed
#     immediately; the trailing fragment carries over into the next token.
#   - After [DONE], any remaining buffer fragment is flushed as a final sentence.
#     This handles responses that end without terminal punctuation.
#
# TODO: Parse tool_calls in delta content once agentic workflows are added.
def query_llama(conn, history, sg)
  buffer    = ""
  full_resp = ""

  begin
    conn.post("/v1/chat/completions") do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["Accept"]       = "text/event-stream"
      req.body = JSON.generate(
        model:       "devstral",
        messages:    history,
        stream:      true,
        temperature: 0.7,
        max_tokens:  512
      )
      req.options.on_data = proc do |chunk, _bytes| # rubocop:disable Lint/UnusedBlockArgument
        chunk.each_line do |line|
          line = line.strip
          next unless line.start_with?("data: ")
          payload = line.sub(/^data: /, "")
          next if payload == "[DONE]"

          begin
            data = JSON.parse(payload)
            token = data.dig("choices", 0, "delta", "content")
            next if token.nil? || token.empty?

            buffer    << token
            full_resp << token

            if buffer =~ /#{SENTENCE_BOUNDARY}/
              parts = buffer.split(SENTENCE_BOUNDARY)
              parts[0..-2].each do |sentence|
                flush_sentence(sg, sentence)
              end
              buffer = parts.last.to_s
            end
          rescue JSON::ParserError => e
            $stderr.puts "[maestro] Malformed SSE chunk, skipping: #{e.message}"
          end
        end
      end
    end
  rescue => e
    $stderr.puts "[maestro] LLM request failed (#{e.message})"
    raise
  end

  # Flush any trailing fragment (e.g. response ends without sentence-terminal punctuation)
  flush_sentence(sg, buffer) unless buffer.strip.empty?

  full_resp
end

# --- Main loop ----------------------------------------------------------------
$stderr.puts "[maestro] Starting maestro..."

# In-process history: temporary until server-side conversation storage is implemented.
# The system prompt is injected once at startup and preserved across trim_history calls.
history = [{ role: "system", content: SYSTEM_PROMPT }]
sg      = connect_spriggan
conn    = connect_llama

# Open the whisper input source. If WHISPER_PIPE is a named FIFO, File.open will
# block here until the writer (whisper-stream) connects — this is correct behaviour.
input = WHISPER_PIPE == "/dev/stdin" ? $stdin : File.open(WHISPER_PIPE, "r")

sg.pm2_log "[maestro] Listening on #{WHISPER_PIPE}"

loop do
  line = input.gets
  break if line.nil? # EOF — writer closed the pipe, exit cleanly

  utterance = line.strip
  next if utterance.empty? # whisper emits blank lines between segments; skip them

  sg.pm2_log "[maestro] Heard: #{utterance.inspect}"

  history << { role: "user", content: utterance }
  history = trim_history(history)

  begin
    response = query_llama(conn, history, sg)
    history << { role: "assistant", content: response }
    history = trim_history(history)
    sg.pm2_log "[maestro] Response complete (#{response.length} chars)"
  rescue => e
    # On any pipeline failure, drop the orphaned user turn from history (it has
    # no corresponding assistant reply) and reconnect both the LLM client and
    # beanstalkd before resuming — PM2 will restart us if this loop itself dies.
    $stderr.puts "[maestro] Pipeline error: #{e.message}, retrying connection in 5s..."
    sleep 5
    sg   = connect_spriggan
    conn = connect_llama
    history.pop
  end
end

sg.pm2_log "[maestro] Input stream closed, exiting."
input.close unless WHISPER_PIPE == "/dev/stdin"
