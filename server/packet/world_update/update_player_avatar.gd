extends ServerBoundPacket

func run(server: Server, sender_id: String, packet_data: Dictionary) -> void:
	var player := server.global_player_list[sender_id]
	if !player: return
	
	var world := server.world_service.get_world(player.world_id)
	if !world: return
	
	var entity := world.entity_service.get_entity(player.entity_id)
	if !entity: return
	
	entity.position = packet_data["position"]
