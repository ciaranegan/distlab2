class Client

	attr_reader :name, :join_id, :socket

	def initialize(name, join_id, socket)
		@name = name
		@join_id = join_id
		@socket = socket
	end

end