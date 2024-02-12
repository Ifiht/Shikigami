#=============<[ Gems ]>=============#
require "require_all"
#==========<[ Local Libs ]>==========#
require_rel "../../lib/shiki_gram"
require_rel "../../lib/app_settings"
require_relative "lib_habitica"

sgram = ShikiGram.new
@habit = HabActions.new
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")


bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
bstalk.tubes.find("habitica") # also creates the tube
bstalk.tubes.watch!("habitica")

def log_to_pm2(message)
  $stdout.puts message
  $stdout.flush
end

loop do
  job = bstalk.tubes.reserve
  if job.exists?
    str = sgram.open_msg(job.body)
    log_to_pm2("Received job: #{str}")
    begin
      eval_string(str)
    rescue e
      log_to_pm2("Rescued job: #{e}")
    end
    job.delete
  end #if
  sleep 0.00024
end #loop
