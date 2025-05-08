class_name GamePackLoader extends Node


var game_packs: Dictionary[String, GamePack] = {}

func load_game_pack(game_pack_dir: String) -> void:
	var _game_pack := GamePack.new(game_pack_dir)