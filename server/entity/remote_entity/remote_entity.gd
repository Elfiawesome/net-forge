class_name RemoteEntity extends RefCounted

# References
var world: RemoteWorld
var entity_type: String
var entity_id: String

var position: Vector2

func get_universe_reference() -> Array[String]:
	return [world.world_type, entity_id]

func serialize() -> Dictionary:
	return {
		"entity_type": entity_type,
		"position": position
	}
