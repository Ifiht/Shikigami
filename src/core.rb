require 'socket'
require './library/lib_config.rb'

cfg = AppSettings.new
HOST = cfg.get("shiki_host")
PORT_MAIN = cfg.get("shiki_port")
#==<[ Connection Ports ]>==#
# Add any connector ports here
# as increments of the main port
CONPORT_EMAIL = PORT_MAIN + 1
CONPORT_FISYS = PORT_MAIN + 2
CONPORT_HABCA = PORT_MAIN + 3
CONPORT_TGRAM = PORT_MAIN + 4

server = TCPServer.new(HOST, PORT_MAIN)
loop do
  Thread.start(server.accept) do |client|
    client.puts "Time is #{Time.now}"
    client.close
  end
end
