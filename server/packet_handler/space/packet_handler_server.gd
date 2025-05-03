class_name SpacePacketHandlerServer extends PacketHandlerServer
# Need a rename lol

func run(server: Server, data: Array, conn: NetworkServerManager.Connection) -> void:
	var space_list: Array = server.space_manager._client_to_spaces_map.get(conn.id, [])
	for space_id: String in space_list:
		if space_id in server.space_manager.spaces:
			var space := server.space_manager.spaces[space_id]
			run_space_level(space, conn.id, data)

func run_space_level(_space: ServerSpaceManager.ServerSpace, _client_id: String, _data: Array) -> void:
	# We don't pass down the conn object because we are limiting the scope of this function in space level only
	pass
