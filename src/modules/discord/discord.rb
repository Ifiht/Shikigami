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

CHAT = "@User: Hello, Wayland.\n@Wayland: Hi.\n@User: Please translate this into binary 'To be or not to be'.\n@Wayland: 010101000110111100100000011000100110010100100000011011110111001000100000011011100110111101110100001000000111010001101111001000000110001001100101"

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
  request = {
    "stream"=> false,
    "n_predict"=> 400,
    "temperature"=> 0,
    "stop"=> ["\n@User:"],
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
# join url: https://discordapp.com/oauth2/authorize?&client_id=CLIENT_ID&scope=bot&permissions=274878155840
core_threads << Thread.new {
  bot = Discordrb::Bot.new token: discord_token
  bot.message(starting_with: "<@1211423563475849236>") do |event|
    msg_body = event.message.content.gsub("<@1211423563475849236>", "").to_s
    log_to_pm2("Received msg: #{msg_body}")
    a = ask_question(CHAT + "\n@User: " + msg_body + "\n@Wayland:")
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
