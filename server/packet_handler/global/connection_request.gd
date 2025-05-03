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
	
	# Slot this player in bodega_bay and sunny_dunes
	var target_map_id: String
	if conn.id.split("Elfiawesome")[1] == "0" or conn.id.split("Elfiawesome")[1] == "2":
		target_map_id = "bodega_bay"
	else:
		target_map_id = "sunny_dunes"
	
	var target_space_id: String
	if target_map_id in server.space_manager._map_name_to_id:
		target_space_id = server.space_manager._map_name_to_id[target_map_id]
	
	if target_space_id in server.space_manager.spaces:
		server.space_manager.assign_client_to_space(conn.id, target_space_id)
