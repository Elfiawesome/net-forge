class_name PacketHandlerServerSpace extends PacketHandlerServer

func run(server: Server, data: Array, conn: NetworkServerManager.Connection) -> void:
	if conn.id in server.space_manager._client_to_spaces:
		var space_id := server.space_manager._client_to_spaces[conn.id]
		if space_id in server.space_manager.spaces:
			var space := server.space_manager.spaces[space_id]
			run_as_space(space, data, conn)

func run_as_space(_space: ServerSpace, _data: Array, _conn: NetworkServerManager.Connection) -> void:
	pass