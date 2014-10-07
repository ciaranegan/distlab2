require 'socket'

if ARGV[0] == nil
	port_no = 8000 # Default port of 8000 if a port number isn't provided
port_no = ARGV[0]

server = TCPServer.new port_no
loop do
  Thread.start(server.accept) do |client|
    client.puts "Hello !"
    client.puts "Time is #{Time.now}"
    client.close
  end
end