class_name LocalEntity extends Node2D

var entity_id: String
var entity_type: String

func deserialize(data: Dictionary) -> void:
	position = data.get("position", Vector2.ZERO)
