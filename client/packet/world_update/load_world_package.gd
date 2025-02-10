extends ClientBoundPacket

func run(client: Client, packet_data: Dictionary) -> void:
	print(packet_data)
	var world_type: String = packet_data["world_type"]
	
	var scene: PackedScene = Registries.get_resource(Registries.LOCAL_WORLD, world_type)
	var world: LocalWorld= scene.instantiate()
	client.add_child(world)
