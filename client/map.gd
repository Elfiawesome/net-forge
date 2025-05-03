class_name Map extends Node2D
# Visual representation on client side of a map

const ENTITY_SCENE := preload("res://client/entity.tscn")

# Reference to send data
var connection: NetworkClientManager.Connection

var entities: Dictionary[String, Entity] = {}
var local_entity_id: String # The entity that I will be controlling

func create_entity(entity_id: String, initial_state: Dictionary) -> Entity:
	var entity := ENTITY_SCENE.instantiate()
	entities[entity_id] = entity
	add_child(entity)
	entity.deserialize(initial_state)
	# NOTE: Special case, I want the position to immediately update regardless if its local or not
	entity.position = entity.target_position
	if entity_id == local_entity_id:
		set_local_entity_id(entity_id)
	return entity

func remove_entity(entity_id: String) -> void:
	if entities.has(entity_id):
		var entity := entities[entity_id]
		entity.queue_free()
		entities.erase(entity_id)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		connection.send_data("player_map_travel")

func _process(delta: float) -> void:
	# TODO: I have to put the controls somewhere...
	if !local_entity_id: return # No entity to control
	
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction != Vector2.ZERO:
		var move_vector := input_direction.normalized() * Entity.BASE_SPEED * delta
		predict_local_avatar_movement(move_vector)
		
		# 2. Send input to server
		connection.send_data("player_movement_input", [input_direction, delta])

func predict_local_avatar_movement(move: Vector2) -> void:
	# Apply movement directly to local avatar for responsiveness
	if (local_entity_id) and (local_entity_id in entities):
		var local_entity := entities[local_entity_id]
		local_entity.position += move

func set_local_entity_id(new_id: String) -> void:
	if local_entity_id:
		if local_entity_id in entities:
			entities[local_entity_id]._is_local = false
	
	# Just set the local entity first. Wait till entity is created later then we set his _is_local
	local_entity_id = new_id
	if new_id in entities:
		entities[new_id]._is_local = true
