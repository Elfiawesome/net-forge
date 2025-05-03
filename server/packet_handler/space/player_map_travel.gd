extends PacketHandlerServer

func run(server: Server, data: Array, conn: NetworkServerManager.Connection) -> void:
	var space_list: Array = server.space_manager._client_to_spaces_map.get(conn.id, []) as Array
	print(space_list)
	# NOTE: Special case cuz theres no way to know what map id Im in. Theres
	# No way to access '_map_name_to_id' from Space
	if space_list.is_empty(): return
	
	var current_space_id: String = space_list[0]
	var current_space := server.space_manager.spaces[current_space_id]
	
	var current_map_id: String
	if current_space is SpaceMap:
		current_map_id = current_space.map_id
	
	var target_map_id: String = ""
	if current_map_id == "sunny_dunes":
		target_map_id = "bodega_bay"
	else:
		target_map_id = "sunny_dunes"
	
	var target_space_id := server.space_manager._map_name_to_id[target_map_id]
	
	server.space_manager.deassign_client_from_space(conn.id, current_space_id)
	server.space_manager.assign_client_to_space(conn.id, target_space_id)
