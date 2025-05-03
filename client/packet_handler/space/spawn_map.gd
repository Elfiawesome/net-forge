extends PacketHandlerClient

const MAP_SCENE := preload("res://client/map.tscn")

func run(client: Client, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_STRING]): return
	
	if client.map != null:
		#unload that map
		print("unloadmap")
		client.map.queue_free()
		pass
	
	client.map = MAP_SCENE.instantiate()
	client.map.connection = client.network_client_manager.connection
	client.add_child(client.map)
	
	client.map.set_local_entity_id(data[0])
