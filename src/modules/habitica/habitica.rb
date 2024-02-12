#=============<[ Gems ]>=============#
require "require_all"
#==========<[ Local Libs ]>==========#
require_rel "../../lib/shiki_gram"
require_rel "../../lib/app_settings"
require_relative "lib_habitica"

sgram = ShikiGram.new
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")

#[[[[[[ PORT CHECK FOR SHIKIGAMI EXTERNAL RESOURCES ]]]]]]
if port_open?(beanstalk_host, beanstalk_port)

  #[[[[[[ DEFINE THREADS ]]]]]]
  core_threads = []
  job_threads = []
  a = [] # empty holder array for jobs
  semaphore = Mutex.new
  bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
  bstalk.tubes.find("core") # also creates the tube
  bstalk.tubes.watch!("core")

core_threads << Thread.new {
  loop do
    job = bstalk.tubes.reserve
    if job.exists?
      str = sgram.open_msg(job.body)
      log_to_pm2("Received job: #{str}")
      semaphore.synchronize { # Only modify job_threads in semaphore
        job_threads << Thread.new {
          eval_string(str)
          Thread.current.exit
        }
      }
      job.delete
    end #if
    sleep 0.00024
  end #loop
}
