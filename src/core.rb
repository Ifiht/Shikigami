#=============<[ Gems ]>=============#
require 'json'
require 'beaneater'
#==========<[ Local Libs ]>==========#
require './library/lib_core_config.rb'
require './library/lib_habitica.rb'
require './library/lib_telegram.rb'

core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")
habitica_usrid = core_config.get("api_habitica_usrid")
habitica_token = core_config.get("api_habitica_token")

habitica = HabActions.new(habitica_usrid, habitica_token)
#habitica.msgParty('Hello world.')

thread_habitica = Thread.start do
  bstalk_habitica = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
  bstalk_habitica.tubes.watch!('tb_manual')
  loop do
    job = bstalk_habitica.tubes.reserve
    if job.exists?
      eval job.body
      job.delete
    end
  end
end

thread_habitica.join
