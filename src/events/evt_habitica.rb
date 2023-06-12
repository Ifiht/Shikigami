require './library/lib_config.rb'
require './library/lib_habitica.rb'

cfg = AppSettings.new

hab = HabActions.new(cfg.get("api_habitica_usrid"), cfg.get("api_habitica_token"))

#hab.joinQuest
#hab.cron
#hab.getTasks
hab.msgParty("Hello, humans.")
