class_name SpaceMap extends ServerSpaceManager.ServerSpace
# Here we can store all entities in the area etc etc

var map_id: String
var map_area_name: String = "null"
var entities: Dictionary[String, EntityState] = {}
var _client_id_to_entity_id: Dictionary[String, String] = {} # For when we need to move entity around during client input

func _process(delta: float) -> void:
	var snapshot := get_entities_snapshot()
	if !snapshot.is_empty():
		broadcast_data("entity_snapshot", [snapshot])

func add_client_to_space(client_id: String) -> void:
	super.add_client_to_space(client_id)
	
	# Create entity and store inside map
	var entity_state := create_entity()
	_client_id_to_entity_id[client_id] = entity_state.id
	
	# Inject some funny data
	entity_state.position = Vector2(randf_range(0, 500), randf_range(0, 500))
	
	# TODO: rn the map is all the same
	send_data(client_id, "spawn_map", [entity_state.id])
	
	broadcast_data("entity_snapshot", [get_entities_snapshot(true)])

func remove_client_from_space(client_id: String) -> void:
	super.remove_client_from_space(client_id)
	
	if client_id in _client_id_to_entity_id:
		var entity_id := _client_id_to_entity_id[client_id]
		broadcast_data("despawn_entity", [entity_id])
		
		destroy_entity(entity_id)
		
		_client_id_to_entity_id.erase(entity_id)


func get_entities_snapshot(take_everyone: bool = false) -> Dictionary:
	var entities_snapshot: Dictionary = {}
	for entity_id in entities:
		var entity := entities[entity_id]
		if entity.needs_state_update or take_everyone:
			entities_snapshot[entity_id] = entity.serialize()
			entity.needs_state_update = false
	return entities_snapshot

func create_entity() -> EntityState:
	var entity := EntityState.new()
	entity.id = UUID.v4()
	entities[entity.id] = entity
	return entity

func destroy_entity(entity_id: String) -> void:
	if entity_id in entities:
		entities.erase(entity_id) # EntityState will self cleanup

func load_from_json(map_json: Dictionary) -> void:
	name = map_json.get("name", "null")
	name = "MAP_" + name
	
	print("Loaded '%s' map from JSON!" % name)

func save_into_json() -> Dictionary:
	return {
		
	}

class EntityState:
	var id: String
	
	var position: Vector2
	var needs_state_update: bool = false
	
	func serialize() -> Dictionary:
		return {
			"position": position,
		}
