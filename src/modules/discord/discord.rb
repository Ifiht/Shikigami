#=============<[ Gems ]>======================#
require "http"
require "json"
require "spriggan"
require "redfairy"
require "discordrb"

#=============<[ Local Vars ]>================#
core_config = RedFairy.new("shikigami")

#=============<[ Instance Vars ]>=============#
@discord_token = core_config.get("api_discord_token")
@beanstalk_host = core_config.get("beanstalk_host")
@beanstalk_port = core_config.get("beanstalk_port")

@sprig = Spriggan.new(
  beanstalk_host: @beanstalk_host,
  beanstalk_port: @beanstalk_port,
  module_name: "discord",
)

#=============<[ Constants ]>================#
INST = "A chat between a very important human and an artificial intelligence assistant. The assistant gives quick and truthful answers to the human's questions. The assistant's responses are thorough, but succinct."
CHAT = "\n@User: Hello.\n@Wayland: Greetings.\n@User: What do you call yourself?\n@Wayland: Wayland.\n@User: What is the closest star to our sun?\n@Wayland: The closest star to our sun Sol is Alpha Centauri."

#=============<[ Methods ]>==================#
# Evaluates a string and logs to PM2 on error
def eval_string(str)
  begin
    eval str
  rescue SyntaxError
    @sprig.pm2_log("SyntaxError: #{str}")
  rescue NameError
    @sprig.pm2_log("NameError: #{str}")
  end #begin
end #def

# Parameters passed to llama.cpp running Llama 3
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

# HTTP request interface to llama.cpp server
def ask_question(q)
  question = format_question(q)
  response = HTTP.post("http://localhost:4242/completion", :json => question)
  h = JSON.parse(response.body)
  return h["content"]
end #def

# Discord chat logic to receive msg and send response
def respond(e)
  #@sprig.pm2_log("Received msg: #{e.message.content}")
  msg_body = e.message.content.gsub("<@1211423563475849236>", "Wayland").gsub("<@&1211432785353637999>", "Wayland").to_s
  e.channel.start_typing
  a = ask_question(INST + CHAT + "\n@User: " + msg_body + "\n@Wayland:")
  @sprig.pm2_log("Sending msg: #{a}")
  if a.include? "@Wayland:"
    e.respond a.gsub("@Wayland:", "").to_s
  else
    e.respond a.to_s
  end #if
end #def

#============================================#
#+++-----      <[ Main Body ]>       -----+++#
#============================================#
# join url: https://discordapp.com/oauth2/authorize?&client_id=1211423563475849236&scope=bot&permissions=274878155840
@sprig.add_thread {
  loop do
    msg_hash = @sprig.get_msg
    begin
      eval_string(msg_hash["msg"])
    rescue Exception => e
      @sprig.pm2_log("Rescued job: #{e}")
    end #begin
  end #loop
}
@sprig.add_thread {
  bot = Discordrb::Bot.new token: @discord_token
  #bot.message(starting_with: "<@1211423563475849236>") do |event|
  #bot.message(starting_with: "<@&1211432785353637999>") do |event|
  bot.message do |event|
    @sprig.pm2_log("Received message #{event.message}")
  bot.mention do |event|
    @sprig.pm2_log("Responding to event")
    respond(event)
  end
  at_exit { bot.stop }
  bot.run
}

#[[[[[[ RUN THREADS ]]]]]]
@sprig.run
