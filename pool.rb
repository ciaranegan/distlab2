require 'socket'
require 'thread'

class ThreadPoolServer

	def initialize(size, port_no)
		@size = size
		@jobs = Queue.new
		@pool = Array.new(@size) do |i|
			Thread.new do
				# Give an ID to each thread for easy identification later
				Thread.current[:id] = i
				loop do
					# Pop the job at the top of the queue and execute it
					client, message = @jobs.pop
					if message == "HELO text\n"
						puts "Inside if section start"
						puts "Inside if section"
						puts client
						client.puts "HELLO"
						puts "After client.puts"
						# client.puts "HELO text\nIP: #{@server.addr[0]}\nPort: #{@server.add[1]}\nStudentID: 11450212"
					else
						puts client, message
						client.puts message
					end
				end
			end
		end
		@server = TCPServer.new port_no
		@server_running = true
		self.run
	end

	def schedule(client, message)
		# Pass a client and its message to the queue
		@jobs << [client, message]
	end

	def shutdown
		@size.times do |i|
			# Exit each thread
			Thread.kill(@pool[i])
		end
		@server.close
		puts "Server closed"
	end


	def run
		puts "Server running..."
		while @server_running == true do
			puts "New Thread"
			Thread.start(@server.accept) do |client|
				puts "Up top"
				message = client.gets
				puts message
				if message == "KILL_SERVICE\n"
					puts "Inside if"
					client.puts "Server Terminated"
					@server_running = false
					puts "Hello #{@server_running}"
					puts @server_running
				else
					schedule(client, message)
				end
				client.close
			end
			puts "END OF WHILE"
		end
		self.shutdown
	end
end


# ==============================
# Read in port number from cmd line args
port_no = ARGV[0]

# Initialize the threadpool
server = ThreadPoolServer.new(20, port_no)