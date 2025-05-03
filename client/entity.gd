class_name Entity extends Node2D
# Simple base entity class
# Though i wanna use composition not inheritance

const BASE_SPEED = 300
const RECONCILE_LERP_FACTOR: float = 0.2 # with authoritative server position. Value between 0 and 1.
const REMOTE_INTERPOLATION_SPEED: float = 20.0 # Interpolation speed for remote avatars. Higher value means faster snapping.

## To determine if we are the local_entity_id or not.
## If this is false, means we are not client.
## But if this is true, this means we are the client.
var _is_local: bool = false

var target_position: Vector2

func _ready() -> void:
	target_position = position

func _process(delta: float) -> void:
	if !_is_local:
		position = lerp(position, target_position, delta * REMOTE_INTERPOLATION_SPEED)

func deserialize(data: Dictionary) -> void:
	var server_pos: Vector2 = data.get("position", position)
	if _is_local:
		position = lerp(position, server_pos, RECONCILE_LERP_FACTOR)
		target_position = position
	else:
		target_position = server_pos
