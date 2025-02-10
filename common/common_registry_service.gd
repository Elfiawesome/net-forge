class_name CommonRegistryService extends Node

static func register_client_resource() -> void:
	_register_all_scripts_in_folder(Registries.CLIENT_BOUND_PACKET, "res://client/packet/", false)

static func register_server_resource() -> void:
	_register_all_scripts_in_folder(Registries.SERVER_BOUND_PACKET, "res://server/packet/", false)

static func _register_all_scripts_in_folder(registry_category: String, base_path : String, as_resource: bool = true) -> void:
	for filepath in _get_all_files_from_directory(base_path):
		var filename := filepath.split(base_path)[-1].split(".")[0]
		var gdscript: GDScript = load(filepath)
		if as_resource:
			Registries.register_resource(registry_category, filename, gdscript)
		else:
			var packet: Object = gdscript.new()
			Registries.register_instance(registry_category, filename, packet)

static func _get_all_files_from_directory(path : String, file_ext:= "gd", files: Array[String] = []) -> Array[String]:
	var resources := ResourceLoader.list_directory(path)
	for res in resources:
		if res.ends_with("/"): 
			var _a := _get_all_files_from_directory(path+res, file_ext, files)
		elif file_ext && res.ends_with(file_ext): 
			files.append(path+res)
	return files
