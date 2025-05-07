extends PacketHandlerServer

# We reverse whatever we did in connection_request
func run(server: Server, _data: Array, conn: NetworkServerManager.Connection) -> void:
	var client_id: String = conn.id
	if client_id != "":
		pass
		# STEP 1: Remove client from NetworkManager
		if server.network_manager.connections.has(client_id):
			server.network_manager.connections.erase(client_id)
		
		# STEP 2: Unload him from PlayerStatesManager (NOTE: For now we will save it on server level instead of manager level)
		if server.player_states_manager.has_player(client_id):
			server.server_bus.persitance.save_player_data(client_id, 
				server.player_states_manager.get_player(client_id).to_dict()
			)
			server.player_states_manager.remove_player(client_id)

		# STEP 3: Remove him from space
		server.space_manager.deassign_client_from_space(client_id)
