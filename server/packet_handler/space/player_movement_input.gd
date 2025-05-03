extends SpacePacketHandlerServer

func run_space_level(space: ServerSpaceManager.ServerSpace, client_id: String, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_VECTOR2, TYPE_FLOAT]): return
	if !(space is SpaceMap): return
	
	var space_map := space as SpaceMap
	if client_id in space_map._client_id_to_entity_id:
		var entity_id := space_map._client_id_to_entity_id[client_id]
		var entity := space_map.entities[entity_id]
		
		entity.position += (data[0] as Vector2) * Entity.BASE_SPEED * (data[1] as float)
		entity.needs_state_update = true
