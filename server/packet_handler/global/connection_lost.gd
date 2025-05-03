extends PacketHandlerServer
# Reverse of connection_request
# Clean up all instances from this client

func run(server: Server, _data: Array, conn: NetworkServerManager.Connection) -> void:
	if conn.id != "":
		if server.network_manager.connections.has(conn.id):
			server.network_manager.connections.erase(conn.id)
			
		# Remove from any connected spaces
		if server.space_manager._client_to_spaces_map.has(conn.id):
			var space_list := server.space_manager._client_to_spaces_map[conn.id]
			for space_id: String in space_list:
				if space_id in server.space_manager.spaces:
					server.space_manager.spaces[space_id].remove_client_from_space(conn.id)
