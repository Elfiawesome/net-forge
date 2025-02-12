extends ClientBoundPacket

func run(client: Client, packet_data: Dictionary) -> void:
	if client.loaded_world:
		# Unload that world first
		client.loaded_world.queue_free()
	
	var snapshot: Dictionary = packet_data["snapshot"]
	load_snapshot(client, snapshot)
	
	client.loaded_world.player_controller.target_entity = client.loaded_world._entities[packet_data["owned_entity_id"]]
	
	client.loaded_world.player_controller.data_send.connect(
		func(packet_name: String, packet_data: Dictionary) -> void:
			client.network_layer.send_data(packet_name, packet_data)
	)

func load_snapshot(client: Client, snapshot_data: Dictionary) -> void:
	var world_type: String = snapshot_data["world_type"]
	
	var world_resource: PackedScene = Registries.get_resource(Registries.LOCAL_WORLD, world_type)
	var world: LocalWorld = world_resource.instantiate()
	client.add_child(world)
	client.loaded_world = world
	
	var entities_data: Dictionary = snapshot_data["entities"]
	for entity_id: String in entities_data:
		var entity_data: Dictionary = entities_data[entity_id]
		var entity_type: String = entity_data.get("entity_type", "")
		var entity := world.add_entity(entity_id, entity_type, entity_data)
	
