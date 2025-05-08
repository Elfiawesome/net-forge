class_name PersistanceManager extends Node

var dir: DirAccess
var bus: PersistanceBus
# TODO!!! Make this server config as a game_config and make it common. Since client also needs to replicate this over
var server_config: ServerConfig # A read only reference of server configs

const GAME_DATA_PATH := "res://.temp-saves/" # "user://" for now we use the game project file to debug

const FOLDERS = {
	PLAYER_DATA = "player_data",
}

func _ready() -> void:
	bus = PersistanceBus.new(self)

func new_save(save_name: String) -> void:
	var save_dir := GAME_DATA_PATH + "saves/" + save_name
	print(GAME_DATA_PATH)
	if !DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_recursive_absolute(save_dir)
	dir = DirAccess.open(save_dir)
	load_save(save_name)

func load_save(_save_name: String) -> void:
	if dir == null: return
	_load_server_config()

func _load_server_config() -> void:
	if dir == null: return
	const SERVER_CONFIG_FILE := "server_config.json" # Can default config file to something else i guess
	var config_file_path := dir.get_current_dir() + "/" + SERVER_CONFIG_FILE
	var config_data := open_file_as_json(config_file_path)
	server_config = ServerConfig.new()
	if config_data.is_empty():
		save_file_as_json(config_file_path, server_config.to_json())
	else:
		server_config.from_json(config_data)


func open_file_as_variant(bytes_file_path: String) -> Variant:
	var data: Variant = null
	if !DirAccess.dir_exists_absolute(bytes_file_path.get_base_dir()): DirAccess.make_dir_recursive_absolute(bytes_file_path.get_base_dir())
	if FileAccess.file_exists(bytes_file_path):
		var f := FileAccess.open(bytes_file_path, FileAccess.READ)
		if f:
			data = bytes_to_var(f.get_buffer(f.get_length()))
			f.close()
	return data

func save_file_as_variant(bytes_file_path: String, data: Variant) -> void:
	if !DirAccess.dir_exists_absolute(bytes_file_path.get_base_dir()): DirAccess.make_dir_recursive_absolute(bytes_file_path.get_base_dir())
	if !FileAccess.file_exists(bytes_file_path):
		var f := FileAccess.open(bytes_file_path, FileAccess.WRITE)
		if f:
			f.store_buffer(var_to_bytes(data))
			f.close()

func open_file_as_json(json_file_path: String) -> Dictionary:
	var data: Dictionary
	if !DirAccess.dir_exists_absolute(json_file_path.get_base_dir()): DirAccess.make_dir_recursive_absolute(json_file_path.get_base_dir())
	if FileAccess.file_exists(json_file_path):
		var f := FileAccess.open(json_file_path, FileAccess.READ)
		if f:
			data = JSON.parse_string(f.get_as_text())
			f.close()
	return data

func save_file_as_json(json_file_path: String, data: Dictionary) -> void:
	if !DirAccess.dir_exists_absolute(json_file_path.get_base_dir()): DirAccess.make_dir_recursive_absolute(json_file_path.get_base_dir())
	if !FileAccess.file_exists(json_file_path):
		var f := FileAccess.open(json_file_path, FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify(data))
			f.close()

class PersistanceBus:
	var _persistance_manager: PersistanceManager

	func _init(persistance_manager_: PersistanceManager) -> void:
		_persistance_manager = persistance_manager_
	
	func get_dir() -> DirAccess:
		return _persistance_manager.dir

	func get_server_config() -> ServerConfig:
		if _persistance_manager.server_config == null: _persistance_manager.server_config = ServerConfig.new()
		return _persistance_manager.server_config

	func load_player_data(client_id: String) -> Dictionary:
		var player_data: Variant = _persistance_manager.open_file_as_variant(
			get_dir().get_current_dir() + "/" + FOLDERS.PLAYER_DATA + "/" + client_id + ".playerdat"
		)
		if player_data is Dictionary:
			return player_data
		return {}
	
	func save_player_data(client_id: String, data: Dictionary) -> void:
		_persistance_manager.save_file_as_variant(
			get_dir().get_current_dir() + "/" + FOLDERS.PLAYER_DATA + "/" + client_id + ".playerdat"			
			,data
		)
