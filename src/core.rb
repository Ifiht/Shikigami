#=============<[ Gems ]>=============#
require "json"
require "socket"
require "beaneater"
require "concurrent"
#==========<[ Local Libs ]>==========#
require_relative "./library/lib_core_config"
#require_relative "./library/lib_core_bstalk"
require_relative "./library/lib_habitica"
require_relative "./library/lib_telegram"

#[[[[[[ INITIALIZE CONFIG & ALL LIBRARY CLASSES HERE]]]]]]
core_config = AppSettings.new
beanstalk_host = core_config.get("beanstalk_host")
beanstalk_port = core_config.get("beanstalk_port")
habitica_usrid = core_config.get("api_habitica_usrid")
habitica_token = core_config.get("api_habitica_token")

habitica = HabActions.new(habitica_usrid, habitica_token)
#habitica.msgParty('Hello world.')

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

#[[[[[[ PORT CHECK FOR SHIKIGAMI EXTERNAL RESOURCES ]]]]]]
if port_open?(beanstalk_host, beanstalk_port)

  #[[[[[[ DEFINE THREADS ]]]]]]
  core_threads = []
  eval_threads = []
  semaphore = Mutex.new
  bstalk = Beaneater.new("#{beanstalk_host}\:#{beanstalk_port}")
  bstalk.tubes.find("tb_manual")
  bstalk.tubes.find("tb_filesystem")
  bstalk.tubes.watch("tb_manual")
  bstalk.tubes.watch("tb_filesystem")

  core_threads << Thread.new {
    loop do
      job = bstalk.tubes.reserve
      if job.exists?
        semaphore.synchronize {
          eval_threads << Thread.new {
            begin
              eval job.body
            rescue SyntaxError
              puts "SyntaxError: #{job.body}"
            rescue NameError
              puts "NameError: #{job.body}"
            ensure
              job.delete
              Thread.current.exit
            end #begin
          }
        }
      end #if
    end #loop
  }

  core_threads << Thread.new {
    loop do
      semaphore.synchronize {
        eval_threads.each { |thr| thr.join }
      }
    end #loop
  }

  #[[[[[[ JOIN THREADS ]]]]]]
  core_threads.each { |thr| thr.join }

else
  puts "Cannot initialize threads, beanstalkd not reachable."
  exit 2
end #if
