extends ClientBoundPacket

func run(client: Client, packet_data: Dictionary) -> void:
	for entity_id: String in packet_data["entities"]:
		var entity := client.loaded_world._entities.get(entity_id) as LocalEntity
		if !entity: return
		entity.deserialize(packet_data["entities"][entity_id])
		
