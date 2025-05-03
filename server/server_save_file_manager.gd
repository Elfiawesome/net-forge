class_name SaveFileManager extends Node

const SERVER_CONFIG_FILE = "server-config.json"

var dir: DirAccess
var config: GameConfig

func load_save(save_name: String) -> void:
	if dir == null: return
	
	# Create/Load config file
	load_server_config_file()

func new_save(save_name: String) -> void:
	var save_dir := "user://saves/" + save_name
	if DirAccess.dir_exists_absolute(save_dir):
		pass
	else:
		DirAccess.make_dir_recursive_absolute(save_dir)
	dir = DirAccess.open(save_dir)
	load_save(save_name)


func load_server_config_file() -> void:
	if dir == null: return
	var server_config_file := dir.get_current_dir() + "/" + SERVER_CONFIG_FILE
	config = GameConfig.new()
	if dir.file_exists(SERVER_CONFIG_FILE):
		var f := FileAccess.open(server_config_file, FileAccess.READ)
		if f != null:
			config.from_dict(JSON.parse_string(f.get_as_text()))
	else:
		# Create new config and save it
		var f := FileAccess.open(server_config_file, FileAccess.WRITE)
		f.store_string(JSON.stringify(config.to_dict()))

class GameConfig:
	var port: int
	var address: String
	
	func _init() -> void:
		default()
	
	func default() -> void:
		port = 3115
		address = "127.0.0.1"
	
	func to_dict() -> Dictionary:
		return {
			"port": port,
			"address": address
		}
	
	func from_dict(config_dict: Dictionary) -> void:
		port = config_dict.get("port", port)
		address = config_dict.get("address", address)
