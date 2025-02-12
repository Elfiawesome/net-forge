extends ClientBoundPacket

func run(client: Client, packet_data: Dictionary) -> void:
	if !client.loaded_world:
		printerr("[Client]: Can't add entities to a non-existing world")
		return
	for entity_id: String in packet_data:
		var entity_data: Dictionary = packet_data[entity_id]
		var entity_type: String = entity_data.get("entity_type", "")
		client.loaded_world.add_entity(entity_id, entity_type, entity_data)
