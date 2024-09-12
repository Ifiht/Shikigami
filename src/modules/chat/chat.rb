#=============<[ Gems ]>=============#
require "pg"
require "http"
require "json"
require "spriggan"
require "redfairy"

#=============<[ Constants ]>================#
INST = "A chat between a very important human and an artificial intelligence assistant. The assistant gives quick and truthful answers to the human's questions. The assistant's responses are thorough, but succinct."
CHAT = "\nUser: Hello.\nWayland: Greetings.\nUser: What do you call yourself?\nWayland: Wayland.\nUser: What is the closest star to our sun?\nWayland: The closest star to our sun Sol is Alpha Centauri."

#=============<[ Local Vars ]>================#
core_config = RedFairy.new("shikigami")

#=============<[ Instance Vars ]>=============#
@answer = ""
@db_user = core_config.get("db_user")
@db_pass = core_config.get("db_pass")
@beanstalk_host = core_config.get("beanstalk_host")
@beanstalk_port = core_config.get("beanstalk_port")

@sprig = Spriggan.new(
  beanstalk_host: @beanstalk_host,
  beanstalk_port: @beanstalk_port,
  module_name: "chat",
)

@conn = PG.connect( dbname: 'shikigami' )

#=============<[ Methods ]>==================#
# Parameters passed to llama.cpp running Llama 3
def format_question(prompt, sender)
  i = rand(99)
  jstop = "\n#{sender}:"
  request = {
    "stream" => false,        # keep false, breaks if true
    "seed" => i,              # Set the random number generator (RNG) seed.
    "n_predict" => 500,       # notes
    "temperature" => 0.56,    # was:0, def:0-1, higher is more creative (0.49 failed to answer question about unicorns)
    "stop" => [jstop, "\nUser:"],   # notes
    "repeat_last_n" => 128,   # Last n tokens to consider for penalizing repetition. 0 is disabled and -1 is ctx-size.
    "repeat_penalty" => 1.2,  # Control the repetition of token sequences in the generated text.
    "top_k" => 34,            # def:40, Limit the next token selection to the K most probable tokens.
    "top_p" => 0.92,           # def:0.95, higher finds better predictions, but slower
    "min_p" => 0.06,          # def:0.05, The minimum probability for a token to be considered, relative to the probability of the most likely token.
    "tfs_z" => 1,             # def:1(disabled) https://www.trentonbricken.com/Tail-Free-Sampling/
    "typical_p" => 1,         # def:1(disabled)
    "presence_penalty" => 0,  # def:0(disabled)
    "frequency_penalty" => 0, # def:0(disabled)
    "mirostat" => 0,          # def:0(disabled), 1=Mirostat 1.0, 2=Mirostat 2.0
    "mirostat_tau" => 4.0,    # Set the Mirostat target entropy, parameter tau.
    "mirostat_eta" => 0.1,    # Set the Mirostat learning rate, parameter eta.
    "prompt" => prompt,       # https://github.com/ggerganov/llama.cpp/blob/master/examples/server/README.md
  }
  return request
end #def

# HTTP request interface to llama.cpp server
def ask_question(q, s)
  question = format_question(q, s)
  response = HTTP.post("http://localhost:4242/completion", :json => question)
  h = JSON.parse(response.body)
  return h["content"]
end #def

# Discord chat logic to receive msg and send response
def get_response(question, sender)
  @sprig.pm2_log("Received msg: #{question}")
  answer = ask_question(INST + CHAT + "\n" + question + "\n@Wayland:", sender)
  @sprig.pm2_log("Sending msg: #{answer}")
  if answer.include? "Wayland:"
    @sprig.pm2_log("Wayland string detected, removing..")
    answer.gsub!("Wayland:", "").to_s
  end #if
  return answer.to_s
end #def

#============================================#
#+++-----      <[ Main Body ]>       -----+++#
#============================================#
@sprig.add_thread {
  loop do
    msg_hash = @sprig.get_msg
    begin
      @answer = get_response(msg_hash["msg"], msg_hash["from"])
    rescue Exception => e
      @sprig.pm2_log("Rescued job: #{e}")
    end #begin
    @sprig.send_msg(@answer, msg_hash["from"])
    @answer = ""
  end #loop
}

#[[[[[[ RUN THREADS ]]]]]]
@sprig.run
