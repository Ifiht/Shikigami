#=============<[ Gems ]>=============#
require "json"
require "socket"
require "beaneater"
require "io/console"
require "concurrent"
require "require_all"
#==========<[ Local Libs ]>==========#
require_rel "lib/shiki_gram"
require_rel "lib/pm2_helper"
require_rel "lib/app_settings"

#@@@@@@ USERS MAY EDIT THEIR SETTINGS BELOW:
#[[[[[[ INITIALIZE CONFIG & ALL LIBRARY CLASSES HERE]]]]]]
cwd = %x(pwd).chomp
pm2 = Pm2Helper.new
procs = []
sgram = ShikiGram.new
modules1 = []
modules2 = []
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")

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
  a = [] # empty holder array for jobs
  semaphore = Mutex.new
  bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
  bstalk.tubes.find("core") # also creates the tube
  bstalk.tubes.watch!("core")

  # Core thread to check for jobs and add them to the jobs array
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

  # Core thread to check for new modules
  core_threads << Thread.new {
    loop do
      modules2 = %x[ ls #{cwd}/src/modules ].split
      if modules1 != modules2
        modules1 = modules2
        modules1.each do |m|
          if pm2.processes.include? m
            log_to_pm2("Skipping running module: #{m}")
          else
            if %x[ ls #{cwd}/src/modules/#{m} ].split.include? "wrapper.sh"
              %x[ cd #{cwd}/src/modules/#{m} && pm2 start #{cwd}/src/modules/#{m}/wrapper.sh --name #{m} --watch ]
              log_to_pm2("Starting module: #{m}")
            else
              log_to_pm2("No wrapper for module: #{m}")
            end #if
          end #if
        end #do
      end #if
      sleep 2
    end #loop
  }

  # Core thread to check the jobs array and join if not empty
  core_threads << Thread.new {
    loop do
      if not job_threads.empty?
        semaphore.synchronize { # Only modify job_threads in semaphore
          a = job_threads
          job_threads = []
        } # Moving the jobs to array 'a' allows us to re-use job_threads
        a.each { |thr| thr.join }
      end #if
      sleep 0.00024
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
