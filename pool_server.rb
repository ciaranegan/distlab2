require 'socket'
require 'thread'

require_relative 'chatroom.rb'
require_relative 'chat_client.rb'

class ThreadPoolServer

	def initialize(size, port_no)
		
		chatroom_new = Chatroom.new("hello", 1)

		@size = size # Number of threads in the thread pool
		@jobs = Queue.new # Queue of tasks for the threads to execute
		@port_no = port_no
		@chatrooms = Hash.new
		@client_list = Hash.new

		@pool = Array.new(@size) do |i| # Create an array of threads
			Thread.new do
				Thread.abort_on_exception = true
				Thread.current[:id] = i # Give each thread an ID for easy access later
				loop do
					client, message = @jobs.pop # Get a job from the queue
					self.handle_client(client, message)
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

	def handle_client(client, message)
		puts message.chomp
		case message.chomp
		when "KILL_SERVICE\n"
			client.puts "Server shutdown"

		when /^HELO\s.*/
			# Get the incoming sockets info and send it back
			local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
			client.puts "#{message}IP:#{local_ip}\nPort:#{@port_no}\nStudentID:11450212"

		when /\AJOIN_CHATROOM:(\S+)\\nCLIENT_IP:0\\nPORT:0\\nCLIENT_NAME:(\S+)/
#           room,join_id = add_to_room($1,$2,client)
#           client.puts "JOINED_CHATROOM: #{room.name}\nSERVER_IP: XXX\nPORT: XXX\nROOM_REF: #{room.ref}\nJOIN_ID: #{join_id}\n"
			puts "Inside case"
			room_name = $1
			client_name = $2

			if !@chatrooms.has_key?(room_name)

				new_chat = Chatroom.new(room_name, @chatrooms.length)

				@chatrooms[room_name] = new_chat

				# add chatroom to hash and go on as normal
			end
			puts "Join chatroom '#{message[14..message.index('\n')-1]}'"
			if !@client_list.has_key?(client_name)
				@client_list[client_name] = Client.new(client_name, client_name+room_name, client)
			end
				@chatrooms[room_name].add_client(@client_list[client_name])


		when /^LEAVE_CHATROOM.*/
			puts "leave chatroom"

		when /^DISCONNECT.*/
			puts "disconnect"

		when /CHAT.*/
			puts "chat"
		else
			# This catches the other messages
			client.puts "Invalid message"
		end

	end

	def shutdown
		sleep(0.5)
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