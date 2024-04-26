#=============<[ Gems ]>=============#
require "http"
require "json"
require "discordrb"
require "beaneater"
require "require_all"
#==========<[ Local Libs ]>==========#
#require_rel "../../lib/shiki_gram"
require_rel "../../lib/app_settings"
require_rel "../../lib/shiki_stdlib"

shiki = Shiki.new("discord")
core_config = AppSettings.new
discord_token = core_config.get("api_discord_token")
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")
core_threads = []

bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
bstalk.tubes.find("discord") # also creates the tube
bstalk.tubes.watch!("discord")

INST = "A chat between a very important human and an artificial intelligence assistant. The assistant gives quick and truthful answers to the human's questions. The assistant's responses are thorough, but succinct."
CHAT = "\n@User: Hello.\n@Wayland: Greetings.\n@User: What's your name?\n@Wayland: Wayland.\n@User: What is the closest star to our sun?\n@Wayland: The closest star to our sun Sol is Alpha Centauri."

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

def format_question(prompt)
  i = rand(99)
  request = {
    "stream" => false,        # keep false, breaks if true
    "seed" => i,              # Set the random number generator (RNG) seed.
    "n_predict" => 500,       # notes
    "temperature" => 0.49,     # was:0, def:0-1, higher is more creative
    "stop" => ["\n@User:"],   # notes
    "repeat_last_n" => 128,   # Last n tokens to consider for penalizing repetition. 0 is disabled and -1 is ctx-size.
    "repeat_penalty" => 1.1,  # Control the repetition of token sequences in the generated text.
    "top_k" => 32,            # def:40, Limit the next token selection to the K most probable tokens.
    "top_p" => 0.9,           # def:0.95, higher finds better predictions, but slower
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

def ask_question(q)
  question = format_question(q)
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
        eval_string(str)
      rescue Exception => e
        log_to_pm2("Rescued job: #{e}")
      end
      job.delete
    end #if
    sleep 0.00024
  end #loop
}
# join url: https://discordapp.com/oauth2/authorize?&client_id=1211423563475849236&scope=bot&permissions=274878155840
core_threads << Thread.new {
  bot = Discordrb::Bot.new token: discord_token
  bot.message(starting_with: "<@1211423563475849236>") do |event|
    msg_body = event.message.content.gsub("<@1211423563475849236>", "").to_s
    log_to_pm2("Received msg: #{msg_body}")
    event.channel.start_typing
    a = ask_question(INST + CHAT + "\n@User: " + msg_body + "\n@Wayland:")
    log_to_pm2("Sending msg: #{a}")
    if a.include? "@Wayland:"
      event.respond a.gsub("@Wayland:", "").to_s
    else
      event.respond a.to_s
    end #if
  end
  at_exit { bot.stop }
  bot.run
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
