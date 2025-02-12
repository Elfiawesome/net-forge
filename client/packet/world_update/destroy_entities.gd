extends ClientBoundPacket

func run(client: Client, packet_data: Dictionary) -> void:
	if !client.loaded_world:
		printerr("[Client]: Can't destroy entities in a non-existing world")
		return
	for entity_id: String in packet_data:
		client.loaded_world.destroy_entity(entity_id)
