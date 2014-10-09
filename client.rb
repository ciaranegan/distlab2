require 'socket'

	if ARGV.empty?
		message = "HELO text\n"
	else
		message = ARGV[0]
	end

# Open a tcp socket to localhost
socket = TCPSocket.open 'localhost', 8000

socket.puts message

# Read the returned data
while line = socket.gets
	puts line.chomp
end

socket.close