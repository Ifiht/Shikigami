#=============<[ Gems ]>=============#
require "discordrb"
require "require_all"
#==========<[ Local Libs ]>==========#
require_rel "../../lib/shiki_gram"
require_rel "../../lib/app_settings"

core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")
habitica_token = core_config.get("habitica_token")

# join url: https://discordapp.com/oauth2/authorize?&client_id=CLIENT_ID&scope=bot&permissions=274878155840
bot = Discordrb::Bot.new token: habitica_token

bot.message(with_text: "Ping!") do |event|
  event.respond "Pong!"
end

at_exit { bot.stop }
bot.run
