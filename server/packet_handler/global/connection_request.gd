extends PacketHandlerServer

func run(server: Server, data: Array, conn: NetworkServerManager.Connection) -> void:
	if !Schema.is_valid(data, [TYPE_DICTIONARY]): return
	
	var request_data: Dictionary = data[0]
	var username: String = request_data.get("username", "")

	var hash_id := username # TODO: hash the username
	if hash_id in server.network_manager.connections:
		conn.force_disconnect("A username is already in this server!")
		return

	# STEP 1: Add to NetworkManager for network communication
	# Add player connection to the network 
	server.network_manager.connections[hash_id] = conn
	conn.id = hash_id
	conn._is_conencted = true
	conn.send_data("request_accepted", [server.persistance_manager.server_config.to_json()])
	
	# STEP 2: Add to PlayerStatesManager for global player state
	# load player data from save & create save file if he doesnt have a save
	var player_data := server.persistance_manager.bus.load_player_data(conn.id) as Dictionary
	server.player_states_manager.add_player(
		conn.id,
		username,
		player_data
	)
	if player_data.is_empty():
		server.persistance_manager.bus.save_player_data(
			conn.id, 
			server.player_states_manager.get_player(conn.id).to_dict()
		)
	
	# STEP 3: Add him to a space
	var new_space := server.space_manager.add_space("space")
	if new_space: server.space_manager.assign_client_to_space(conn.id, new_space.id)
