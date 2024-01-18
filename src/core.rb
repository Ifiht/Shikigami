#=============<[ Gems ]>=============#
require "json"
require "socket"
require "beaneater"
require "io/console"
require "concurrent"
require "require_all"
#==========<[ Local Libs ]>==========#
require_rel "lib"

#@@@@@@ USERS MAY EDIT THEIR SETTINGS BELOW:
#[[[[[[ INITIALIZE CONFIG & ALL LIBRARY CLASSES HERE]]]]]]
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")

############################################################
#@@@@@@@@@@ DO NOT EDIT BELOW THIS LINE!!!! @@@@@@@@@@@@@@@#
############################################################
#[[[[[[ DEFINE CHECK PORT OPEN ]]]]]]
def port_open?(ip, port)
  Timeout::timeout(2) do
    begin
      TCPSocket.new(ip, port).close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
      false
    rescue Timeout::Error
      false
    end #begin
  end #do
end #def

def log_to_pm2(message)
  $stdout.puts message
  $stdout.flush
end

def eval_string(str)
  begin
    eval str
  rescue SyntaxError
    log_to_pm2("SyntaxError: #{str}")
  rescue NameError
    log_to_pm2("NameError: #{str}")
  end #begin
end #def

#[[[[[[ PORT CHECK FOR SHIKIGAMI EXTERNAL RESOURCES ]]]]]]
if port_open?(beanstalk_host, beanstalk_port)

  #[[[[[[ DEFINE THREADS ]]]]]]
  core_threads = []
  job_threads = []
  semaphore = Mutex.new
  bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
  bstalk.tubes.find("core") # also creates the tube
  bstalk.tubes.watch!("core")

  # Core thread to check for jobs and add them to the jobs array
  core_threads << Thread.new {
    loop do
      job = bstalk.tubes.reserve
      if job.exists?
        str = job.body
        log_to_pm2("Received job: #{str}")
        semaphore.synchronize { # Only modify job_threads in semaphore
          job_threads << Thread.new {
            eval_string(str)
            Thread.current.exit
          }
        }
        job.delete
      end #if
    end #loop
  }

  # Core thread to check the jobs array and join if not empty
  core_threads << Thread.new {
    loop do
      if not job_threads.empty?
        a = [] # Initialize empty holder array for jobs
        semaphore.synchronize { # Only modify job_threads in semaphore
          a = job_threads
          job_threads = []
        } # Moving the jobs to array 'a' allows us to re-use job_threads
        a.each { |thr| thr.join }
      end #if
    end #loop
  }

  #[[[[[[ CATCH INTERRUPT ]]]]]]
  Signal.trap("INT") {
    i = 0
    job_threads.each { |t|
      log_to_pm2 "killing job thread #{i}..."
      t.kill
      i += 1
    }
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
else
  puts "Cannot initialize threads, beanstalkd not reachable at #{beanstalk_host}, #{beanstalk_port}."
  exit 2
end #if
