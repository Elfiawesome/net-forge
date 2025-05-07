extends PacketHandlerClient

func run(client: Client, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_STRING]): return
	if client.map == null: return
	
	var entity_id: String = data[0]
	if client.map.entities.has(entity_id):
		client.map.entities[entity_id].queue_free()
