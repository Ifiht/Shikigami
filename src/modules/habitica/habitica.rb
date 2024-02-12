#=============<[ Gems ]>=============#
require "beaneater"
require "require_all"
#==========<[ Local Libs ]>==========#
require_rel "../../lib/shiki_gram"
require_rel "../../lib/app_settings"
require_relative "lib_habitica"

sgram = ShikiGram.new
core_config = AppSettings.new
habitica_usrid = core_config.get("api_habitica_usrid")
habitica_token = core_config.get("api_habitica_token")
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")
core_threads = []
@habitica = HabActions.new(habitica_usrid, habitica_token)

bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
bstalk.tubes.find("habitica") # also creates the tube
bstalk.tubes.watch!("habitica")

def log_to_pm2(message)
  $stdout.puts message
  $stdout.flush
end

core_threads << Thread.new {
  loop do
    job = bstalk.tubes.reserve
    if job.exists?
      str = sgram.open_msg(job.body)
      log_to_pm2("Received job: #{str}")
      begin
        eval_string(str)
      rescue e
        log_to_pm2("Rescued job: #{e}")
        job.delete
      end
      if job.exists?
        job.delete
      end
    end #if
    sleep 0.00024
  end #loop
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
