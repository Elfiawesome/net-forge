extends PacketHandlerServer
# Reverse of connection_request
# Clean up all instances from this client

func run(server: Server, _data: Array, conn: NetworkServerManager.Connection) -> void:
	if conn.id != "":
		if server.network_server_manager.connections.has(conn.id):
			server.network_server_manager.connections.erase(conn.id)
	else:
		pass
