class_name PlayerStatesManager extends Node

var bus: PlayerStatesBus
var player_states: Dictionary[String, PlayerState] = {}

func add_player(client_id: String, username: String, player_data: Dictionary) -> void:
	if client_id in player_states:
		return

	var player_state: PlayerState = PlayerState.new(username)
	player_state.from_dict(player_data) # For now we load the player data from outside of the playerstates manager. There isnt really a need to have a persistance_bus in here anyways.
	player_states[client_id] = player_state

func get_player(client_id: String) -> PlayerState:
	return player_states.get(client_id, PlayerState.new("null"))

func remove_player(client_id: String) -> void:
	if !has_player(client_id): return
	player_states.erase(client_id)

func has_player(client_id: String) -> bool: return player_states.has(client_id)

# Holds the global data that is persistant across all spaces
class PlayerState:
	var username: String = "null"
	var rank: String = ""
	var level: int = 0

	func _init(username_: String) -> void:
		username = username_

	func to_dict() -> Dictionary:
		return {
			"username": username,
			"rank": rank,
			"level": level
		}
	func from_dict(data: Dictionary) -> void:
		username = data.get("username", "")
		rank = data.get("rank", "")
		level = data.get("level", 0)

class PlayerStatesBus:
	pass
