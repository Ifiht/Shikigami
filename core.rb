require 'socket'
require './library/lib_config.rb'

cfg = AppSettings.new

server = TCPServer.new(cfg.get("shiki_host"), cfg.get("shiki_port")) # Server bind to port 1025
loop do
  client = server.accept    # Wait for a client to connect
  client.puts "Hello !"
  client.puts "Time is #{Time.now}"
  client.close
end
