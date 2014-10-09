require 'socket'

# Open a tcp socket to localhost
socket = TCPSocket.open 'localhost', 8000


socket.puts "KILL_SERVICE\n"

# Read the returned data
while line = socket.gets
	puts line.chomp
end

socket.close