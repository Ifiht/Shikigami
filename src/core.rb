require 'socket'
require './library/lib_config.rb'

cfg = AppSettings.new
host = cfg.get("shiki_host")
port = cfg.get("shiki_port")

server = TCPServer.new(host, port)
loop do
  Thread.start(server.accept) do |client|
    client.puts "Time is #{Time.now}"
    client.close
  end
end
