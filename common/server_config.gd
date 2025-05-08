class_name ServerConfig extends Node

var port: int = 51134
var address: String = "127.0.0.1"
var max_players: int = 10
var player := {
	base_speed = 400
}

func to_json() -> Dictionary: return {
	"port": port, "address": address, "max_players": max_players,
	"player": {
		"base_speed": player.base_speed
	}
}

func from_json(json: Dictionary) -> void:
	port = json.get("port", port) as int
	address = json.get("address", address) as String
	max_players = json.get("max_players", max_players) as int

	var _player := json.get("player", {}) as Dictionary
	if _player:
		player.base_speed = _player.get("base_speed", player.base_speed) as int
