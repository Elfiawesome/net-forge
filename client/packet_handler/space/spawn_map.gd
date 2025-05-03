extends PacketHandlerClient

const MAP_SCENE := preload("res://client/map.tscn")

func run(client: Client, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_COLOR]): return
	
	if client.map != null:
		#unload that map
		client.map.queue_free()
		pass
	
	client.map = MAP_SCENE.instantiate()
	client.add_child(client.map)
