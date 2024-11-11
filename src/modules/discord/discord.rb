#=============<[ Gems ]>======================#
require "http"
require "json"
require "spriggan"
require "redfairy"
require "discordrb"

#=============<[ Constants ]>================#
DISCORD_USERS2IDS = YAML.load_file("./disc_u2i.yml")
DISCORD_IDS2USERS = YAML.load_file("./disc_i2u.yml")

#=============<[ Local Vars ]>================#
core_config = RedFairy.new("shikigami")

#=============<[ Instance Vars ]>=============#
@discord_usr_id_map = core_config.get("api_discord_token")
@discord_usr_name_map = core_config.get("api_discord_token")
@discord_token = core_config.get("api_discord_token")
@beanstalk_host = core_config.get("beanstalk_host")
@beanstalk_port = core_config.get("beanstalk_port")

@sprig = Spriggan.new(
  beanstalk_host: @beanstalk_host,
  beanstalk_port: @beanstalk_port,
  module_name: "discord",
)

#=============<[ Methods ]>==================#

# Discord user id translations
def replace_numeric_ids(msg)
  DISCORD_IDS2USERS.each do |k, v|
    msg.gsub!(k, v)
  end
  return msg
end #def

def replace_usernames(msg)
  DISCORD_USERS2IDS.each do |k, v|
    msg.gsub!(k, v)
  end
  return msg
end #def

# Discord chat logic to receive msg and send response
def respond(e)
  if e.message.content.nil?
    msg_body = "SYSTEM: this message was unexpectedly deleted."
  else
    msg_body = e.message.author.username + ": " + e.message.content.to_s
  end
  human_msg_body = replace_numeric_ids(msg_body)
  e.channel.start_typing
  @sprig.pm2_log("Sending query [#{msg_body}] to chat.rb")
  @sprig.send_msg(human_msg_body, "chat")
  msg_hash = @sprig.get_msg # expect a message back
  @sprig.pm2_log("Received response [#{msg_hash.inspect}] from chat.rb")
  a = replace_usernames(msg_hash["msg"].to_s)
  @sprig.pm2_log("Sending msg: #{a}")
  e.respond a
end #def

#============================================#
#+++-----      <[ Main Body ]>       -----+++#
#============================================#
# join url: https://discordapp.com/oauth2/authorize?&client_id=1211423563475849236&scope=bot&permissions=274878155840
#@sprig.add_thread {
#  loop do
#    msg_hash = @sprig.get_msg
#    begin
#      eval_string(msg_hash["msg"])
#    rescue Exception => e
#      @sprig.pm2_log("Rescued job: #{e}")
#    end #begin
#  end #loop
#}

@sprig.add_thread {
  bot = Discordrb::Bot.new token: @discord_token
  #bot.message(starting_with: "<@1211423563475849236>") do |event|
  #bot.message(starting_with: "<@&1211432785353637999>") do |event|
  bot.message do |event|
    @sprig.pm2_log("Received message #{event.message}")
  end
  bot.mention(allow_role_mention: true) do |event|
    @sprig.pm2_log("Bot was mentioned")
    respond(event)
  end
  at_exit { bot.stop }
  bot.run
}

#[[[[[[ RUN THREADS ]]]]]]
@sprig.run
