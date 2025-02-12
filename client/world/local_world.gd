class_name LocalWorld extends Node2D

var _entities: Dictionary[String, LocalEntity] = {}
var player_controller: PlayerController = PlayerController.new()

func _ready() -> void:
	var world_camera: Camera2D = preload("res://client/world/world_camera.tscn").instantiate()
	add_child(world_camera)
	player_controller.camera = world_camera
	add_child(player_controller)

func add_entity(entity_id: String, entity_type: String, entity_data: Dictionary = {}) -> LocalEntity:
	if (entity_id in _entities):
		# Check if existing entity is of same time
		if entity_type == _entities[entity_id].entity_type:
			# If so, it means we just update the visual aspects
			_entities[entity_id].deserialize(entity_data)
			printerr("[Client]: Tried adding entity of same type, overriding data")
		return
	
	var entity_resource: PackedScene = Registries.get_resource(Registries.LOCAL_ENTITY, entity_type)
	var entity: LocalEntity = entity_resource.instantiate()
	
	add_child(entity)
	_entities[entity_id] = entity
	
	entity.entity_id = entity_id
	entity.entity_type = entity_type
	entity.deserialize(entity_data)
	
	return entity

func destroy_entity(entity_id: String) -> void:
	if !(entity_id in _entities):
		printerr("[Client]: Can't destroy an entity that doesn't exist in world")
		return
	_entities[entity_id].queue_free()
	_entities.erase(entity_id)

class PlayerController extends Node:
	
	signal data_send(packet_name: String, packet_data: String)
	
	var target_entity: LocalEntity
	var camera: Camera2D
	
	func _init() -> void:
		pass
	
	func _process(delta: float) -> void:
		if target_entity:
			camera.position = target_entity.position
		
		var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if input_direction != Vector2.ZERO:
			target_entity.position += input_direction * delta * 120
			send_data("world_update/update_player_avatar", {
				"input_direction": input_direction,
				"position": target_entity.position,
			})
	
	func send_data(packet_name: String, packet_data: Dictionary) -> void:
		data_send.emit(packet_name, packet_data)
