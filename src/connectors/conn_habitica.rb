require './library/lib_config.rb'
require './library/lib_habitica.rb'

cfg = AppSettings.new

hab = HabActions.new(cfg.get("api_habitica_usrid"), cfg.get("api_habitica_token"))

#hab.joinQuest
#{"success":true,"data":{"progress":{"collect":{},"hp":100},"active":true,"members":{"3423dac6-ea70-4ab7-9f47-6f29cce6bb43":true,"06240703-3847-47c3-8ee2-eaf75d532d1e":true,"2f6a719a-5735-4e5c-8074-73aae13f625f":true,"b7721622-d0ad-4b6e-ba70-0ece28af2f7c":true},"extra":{},"key":"dustbunnies","leader":"3423dac6-ea70-4ab7-9f47-6f29cce6bb43"},"notifications":[{"type":"NEW_CHAT_MESSAGE","data":{"group":{"id":"9019bd87-f1b5-44d3-af88-70d159d4e77a","name":"Chaotic Neutral Neophytes 🐥⚔️"}},"id":"79958422-f62c-45e6-97aa-83507191cc00","seen":true}],"userV":187,"appVersion":"4.273.1"}
hab.cron

