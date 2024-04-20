#=============<[ Gems ]>=============#
require "http"
require "json"
require "beaneater"
require "require_all"
#==========<[ Local Libs ]>==========#
#require_rel "../../lib/shiki_gram"
require_rel "../../lib/app_settings"
require_rel "../../lib/shiki_stdlib"

shiki = Shiki.new("chat")
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")
core_threads = []

bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
bstalk.tubes.find("chat") # also creates the tube
bstalk.tubes.watch!("chat")

def log_to_pm2(message)
  $stdout.puts message
  $stdout.flush
end #def

def format_question(prompt)
  request = {
    "stream"=> false,
    "n_predict"=> 400,
    "temperature"=> 0,
    "stop"=> [
        "</s>",
    ],
    "repeat_last_n"=> 256,
    "repeat_penalty"=> 1,
    "top_k"=> 20,
    "top_p"=> 0.75,
    "tfs_z"=> 1,
    "typical_p"=> 1,
    "presence_penalty"=> 0,
    "frequency_penalty"=> 0,
    "mirostat"=> 0,
    "mirostat_tau"=> 5,
    "mirostat_eta"=> 0.1,
    "grammar"=> "",
    "n_probs"=> 0,
    "prompt"=> prompt
  }
  return request.to_json
end #def

def ask_question(str)
  question = format_question(str)
  response = HTTP.post("http://localhost:4242/completion", :json => question)
  h = JSON.parse(response.body)
  return h["content"]
end #def

core_threads << Thread.new {
  loop do
    job = bstalk.tubes.reserve
    if job.exists?
      str = sgram.open_msg(job.body)
      log_to_pm2("Received job: #{str}")
      begin
        a = ask_question(str)
      rescue Exception => e
        log_to_pm2("Rescued job: #{e}")
      end
      job.delete
    end #if
    sleep 0.00024
  end #loop
}

#{"tid":"140625866508096","timestamp":1713587850,"level":"INFO","function":"init","line":708,"msg":"initializing slots","n_slots":1}
#{"tid":"140625866508096","timestamp":1713587850,"level":"INFO","function":"init","line":717,"msg":"new slot","id_slot":0,"n_ctx_slot":512}
#{"tid":"140625866508096","timestamp":1713587850,"level":"INFO","function":"main","line":3009,"msg":"model loaded"}
#{"tid":"140625866508096","timestamp":1713587850,"level":"INFO","function":"main","line":3031,"msg":"chat template","chat_example":"[INST] <<SYS>>\nYou are a helpful assistant\n<</SYS>>\n\nHello [/INST] Hi there </s><s>[INST] How are you? [/INST]","built_in":true}
#{"tid":"140625866508096","timestamp":1713587850,"level":"INFO","function":"main","line":3762,"msg":"HTTP server listening","n_threads_http":"1","port":"4242","hostname":"127.0.0.1"}
#{"tid":"140625866508096","timestamp":1713587850,"level":"INFO","function":"update_slots","line":1782,"msg":"all slots are idle"}
#[[[[[[ CATCH INTERRUPT ]]]]]]
Signal.trap("INT") {
  i = 0
  core_threads.each { |t|
    log_to_pm2 "killing core thread #{i}.."
    t.kill
    i += 1
  }
  log_to_pm2 "Exiting gracefully."
  exit
}

#[[[[[[ JOIN THREADS ]]]]]]
core_threads.each { |thr| thr.join }
