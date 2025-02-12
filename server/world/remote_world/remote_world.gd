class_name RemoteWorld extends Node

var world_type: String
var connected_players: Array[String] = []
var entity_service: RemoteEntityService = RemoteEntityService.new(self)

func _ready() -> void:
	add_child(entity_service)
	entity_service.name = "RemoteEntityService"

func get_snapshot() -> Dictionary:
	var data := {
		"world_type": world_type,
		"entities": {}
	}
	for entity_id in entity_service._entities:
		var entity := entity_service._entities[entity_id]
		data["entities"][entity_id] = entity.serialize()
	return data
