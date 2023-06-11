require 'socket'

server = TCPServer.new(HOST, PORT_MAIN)
loop do
  Thread.start(server.accept) do |client|
    client.puts "Time is #{Time.now}"
    client.close
  end
end
