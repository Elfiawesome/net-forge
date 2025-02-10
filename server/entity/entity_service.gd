class_name RemoteEntityService extends Node


var world: RemoteWorld

var _entities: Dictionary[String, RemoteEntity] = {}

func _init(world_: RemoteWorld) -> void:
	world = world_

func create_entity(entity_type: String) -> RemoteEntity:
	var script: GDScript = Registries.get_resource(Registries.REMOTE_ENTITY, entity_type)
	if !script:
		printerr("RemoteEntityService can't create entity type %s" % entity_type)
		return null
	var entity: RemoteEntity = script.new() as RemoteEntity
	var entity_id := _generate_entity_id()
	entity.world = world
	entity.entity_id = entity_id
	entity.entity_type = entity_type
	_entities[entity_id] = entity
	
	return entity

func _generate_entity_id()-> String:
	return str(Time.get_ticks_usec()).sha256_text()
