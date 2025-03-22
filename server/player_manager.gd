extends RefCounted

var _players: Dictionary[String, Player] = {}

class Player extends RefCounted:
	pass

func add_player(player_id: String) -> void:
	if _players.has(player_id): return
	var player := Player.new()
	_players[player_id] = player

func remove_player(player_id: String) -> void:
	if !_players.has(player_id): return
	_players.erase(player_id)

func get_player(player_id: String) -> Player:
	return _players.get(player_id, null)
