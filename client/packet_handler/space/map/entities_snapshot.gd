extends PacketHandlerClient

func run(client: Client, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_DICTIONARY]): return
	if client.map == null: return
	
	var entities_snapshot: Dictionary = data[0]
	for entity_id: String in entities_snapshot:
		var entity_data: Dictionary = entities_snapshot[entity_id]
		if client.map.entities.has(entity_id):
			# Update if have
			client.map.entities[entity_id].deserialize(entity_data)
		else:
			# Create w initial state if dont
			client.map.spawn_entity(entity_id, entity_data)
