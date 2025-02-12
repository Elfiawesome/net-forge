class_name RemoteEntityService extends Node

var world: RemoteWorld

var _entities: Dictionary[String, RemoteEntity] = {}

func _init(world_: RemoteWorld) -> void:
	world = world_

func get_entity(entity_id: String) -> RemoteEntity:
	return _entities.get(entity_id, null)

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

func destroy_entity(entity_id: String) -> void:
	if !(entity_id in _entities):
		printerr("RemoteEntityService can't delete entity id %s because it doesn't exists" % entity_id)
		return
	var _entity := _entities[entity_id]
	_entities.erase(entity_id)

func _generate_entity_id()-> String:
	return str(Time.get_ticks_usec()).sha256_text()
