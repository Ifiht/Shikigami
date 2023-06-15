#=============<[ Gems ]>=============#
require "json"
require "socket"
#==========<[ Local Libs ]>==========#
require_relative "./library/lib_core_config.rb"
require_relative "./library/lib_core_bstalk.rb"
require_relative "./library/lib_habitica.rb"
require_relative "./library/lib_telegram.rb"

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
  thread_manual = Thread.start do
    bstalk_manual = BeanLoop.new(beanstalk_host, beanstalk_port, "tb_manual")
    bstalk_manual.run
  end #thread_manual

  thread_telegram = Thread.start do
    bstalk_telegram = BeanLoop.new(beanstalk_host, beanstalk_port, "tb_telegram")
    bstalk_telegram.run
  end #thread_telegram

  thread_filesystem = Thread.start do
    bstalk_filesystem = BeanLoop.new(beanstalk_host, beanstalk_port, "tb_filesystem")
    bstalk_filesystem.run
  end #thread_filesystem

  #[[[[[[ JOIN THREADS ]]]]]]
  thread_manual.join
  thread_telegram.join
  thread_filesystem.join
else
  puts "Cannot initialize threads, beanstalkd not reachable."
  exit 2
end #if
