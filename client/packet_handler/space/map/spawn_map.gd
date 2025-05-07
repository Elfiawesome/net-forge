extends PacketHandlerClient

func run(client: Client, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_STRING, TYPE_STRING, TYPE_STRING]): return
	
	var local_entity_id: String = data[0]
	var map_name: String = data[1]
	var map_description: String = data[2]
	
	var new_map := client.MAP_SCENE.instantiate()
	new_map.set_local_entity_id(local_entity_id)
	client.set_map(new_map)
	new_map.debug_label.text = "%s \n %s" % [map_name, map_description]
