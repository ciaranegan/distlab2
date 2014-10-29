require 'socket'
require 'thread'

class ThreadPoolServer

	def initialize(size, port_no)
		# Number of threads in the thread pool
		@port_no = port_no
		@size = size
		# Queue of tasks for the threads to execute
		@jobs = Queue.new 
		# Create an array of threads
		@pool = Array.new(@size) do |i|
			Thread.new do
				Thread.current[:id] = i # Give each thread an ID for easy access later
				loop do
					client, message = @jobs.pop # Get a job from the queue
					if message == "KILL_SERVICE\n"
						client.puts "Server shutdown"
					elsif message[0,5] == "HELO "
						# Get the incoming sockets info and send it back
						# port, ip = Socket.unpack_sockaddr_in(@server.peeraddr)
						# sock_domain, remote_port, remote_hostname, remote_ip = @server.peeraddr
						local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
						client.puts "#{message}IP:#{local_ip}\nPort:#{@port_no}\nStudentID:11450212"
						puts "Connected to IP: #{remote_ip} on thread #{Thread.current[:id]}"
					else
						# This catches the other messages
						client.puts "Invalid message"
					end
					client.close
				end
			end
		end
		# Set up TCPServer and start
		@server = TCPServer.new port_no
		@server_running = true
		self.run
	end

	def schedule(client, message)
		# Enqueues a client along with its message for the thread pool to handle
		@jobs << [client, message]
	end

	def shutdown
		# Kills all threads in the thread pool and closes the server
		@size.times do |i|
			Thread.kill(@pool[i])
		end
		@server.close
		puts "Server shutdown"
	end

	def run
		# Main loop to accept incoming messages
		puts "Server started"
		while @server_running == true do
			client = @server.accept
			message = client.gets
			schedule(client, message)
			# Updates the loop condition based on the message
			@server_running = (message != "KILL_SERVICE\n")
		end
		# Shutsdown once a kill_service message is received
		self.shutdown
	end
end

if $0 == __FILE__
	if ARGV[0] == nil
		port_no = 8000
	else
		port_no = ARGV[0]
	end
	server = ThreadPoolServer.new(20, port_no)
end
