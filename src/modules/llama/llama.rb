#=============<[ Gems ]>=============#
require "http"
require 'json'
require "require_all"
#==========<[ Local Libs ]>==========#
#require_rel "../../lib/shiki_gram"
require_rel "../../lib/app_settings"
require_rel "../../lib/shiki_stdlib"

prompt = "Hello world."
req_json = {
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
response = HTTP.post("http://localhost:4242/completion", :json => req_json)
my_hash = JSON.parse(response.body)
puts my_hash["content"]


shiki = Shiki.new("llama")
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")
core_threads = []

bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
bstalk.tubes.find("llama") # also creates the tube
bstalk.tubes.watch!("llama")

def log_to_pm2(message)
  $stdout.puts message
  $stdout.flush
end

def eval_string(str)
  begin
    eval str
  rescue SyntaxError
    log_to_pm2("SyntaxError: #{str}")
  rescue NameError
    log_to_pm2("NameError: #{str}")
  end #begin
end #def

core_threads << Thread.new {
  loop do
    job = bstalk.tubes.reserve
    if job.exists?
      str = sgram.open_msg(job.body)
      log_to_pm2("Received job: #{str}")
      begin
        eval_string(str)
      rescue Exception => e
        log_to_pm2("Rescued job: #{e}")
      end
      job.delete
    end #if
    sleep 0.00024
  end #loop
}

core_threads << Thread.new {
  %x[ ./server -t 12 --threads-http 1 -c 512 --model models/Llama-2-13b-chat-hf/ggml-model-Q4_K_M.gguf --host 127.0.0.1 --port 4242 ]
}

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
