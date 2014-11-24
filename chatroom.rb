require_relative 'chat_client.rb'

class Chatroom

	def initialize(name, room_ref)
		@name = name
		@room_ref = room_ref
		@clients = Hash.new
	end

	def add_client(client)
		@clients[client.name] = client
		client.socket.puts "JOINED_CHATROOM:#{@name}\nSERVER_IP:0\nPORT:0\nJOIN_ID:#{client.join_id}"
	end

	def remove_client(client)
		@clients.delete(client)
	end

	def handle_client(message)
		puts "Hello"
	end
end




# when /\AJOIN_CHATROOM: (\S+)\nCLIENT_IP: 0\nPORT: 0\nCLIENT_NAME: (\S+)/ then
#           room,join_id = add_to_room($1,$2,client)
#           client.puts "JOINED_CHATROOM: #{room.name}\nSERVER_IP: XXX\nPORT: XXX\nROOM_REF: #{room.ref}\nJOIN_ID: #{join_id}\n"