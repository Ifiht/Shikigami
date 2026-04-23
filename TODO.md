# Shikigami — TODO

## Server (`server/`)

- [ ] **Wire template into llama-server** — Add `--chat-template-file ./template.jinja` (and optionally `--host` / `--port`) to `mod_llama/start.sh`.
- [ ] **Run Heretic on Devstral weights** — Use `server/heretic` to produce a decensored GGUF. Update the model path in `start.sh` if the output path differs.

## Client (`client/`)

- [ ] **Implement `mod_whisper`** — Write integration code (shell or C++) that runs `whisper.cpp`'s `stream` binary (or `main` for push-to-talk), captures mic input, and outputs transcribed text. This is the STT entry point.
- [ ] **Fix `mod_piper/start.sh`** — Replace the hardcoded `"Good morning."` test with the proper invocation: pass beanstalkd host/port as args to `hamelin` and pipe output to `ffplay`.
- [ ] **Populate `mod_whisper/whisper.cpp` submodule** — Run `git submodule update --init --recursive` to pull whisper.cpp source, then write a `build.sh` for it.

## Orchestration (missing entirely)

- [ ] **Write the orchestrator process** — A daemon (Ruby, Python, or shell) that:
  1. Reads transcribed text from the `mod_whisper` integration
  2. POSTs to `llama-server`'s `/v1/chat/completions` (OpenAI-compatible, maintains conversation history)
  3. Pushes the LLM response text into beanstalkd's `tts` tube for `hamelin` to consume
- [ ] **Define beanstalkd host/port config** — Standardize how host/port are passed across `piper-serve`, the orchestrator, and any future modules (env vars or a shared config file).

## Process Management

- [ ] **Create `ecosystem.config.js` (PM2)** — Define managed processes for the client: `beanstalkd`, `hamelin` (TTS), whisper listener, orchestrator. Optionally a separate server-side ecosystem file for `llama-server`.
- [ ] **Test full pipeline end-to-end** — Mic → whisper → orchestrator → llama-server → beanstalkd → hamelin → speaker.
