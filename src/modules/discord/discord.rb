#=============<[ Gems ]>=============#
require "discordrb"
require "require_all"
#==========<[ Local Libs ]>==========#
#require_rel "../../lib/shiki_gram"
require_rel "../../lib/app_settings"
require_rel "../../lib/shiki_stdlib"

shiki = Shiki.new("discord")
core_config = AppSettings.new
discord_token = core_config.get("api_discord_token")

# join url: https://discordapp.com/oauth2/authorize?&client_id=CLIENT_ID&scope=bot&permissions=274878155840
bot = Discordrb::Bot.new token: discord_token

bot.message(with_text: "Ping!") do |event|
  event.respond "Pong!"
end

at_exit { bot.stop }
shiki.run(bot.run)
