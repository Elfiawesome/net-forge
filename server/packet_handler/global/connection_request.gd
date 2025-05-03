extends PacketHandlerServer

func run(server: Server, data: Array, conn: NetworkServerManager.Connection) -> void:
	if !Schema.is_valid(data, [TYPE_DICTIONARY]): return
	
	var request_data: Dictionary = data[0]
	var username: String = request_data.get("username", "")

	var hash_id := username # TODO: hash the username
	if hash_id in server.network_manager.connections:
		conn.force_disconnect("A username is already in this server!")
		return
	
	server.network_manager.connections[hash_id] = conn
	conn.id = hash_id
	
	#var space := server.space_manager.ServerSpace.new()
	#server.space_manager.add_space(space)
	#server.space_manager.assign_client_to_space(conn.id, space.id)
