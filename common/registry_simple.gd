class_name RegistrySimple extends RefCounted

var _map: Dictionary[String, Object] = {}

enum InstantiationType {
	REGISTER_RESOURCE,
	INSTANCE_AS_CLASS
}

func get_object(name: String) -> Object:
	return _map.get(name)

func register_object(name: String, object: Variant) -> void:
	_map.set(name, object)

func register_all_objects_in_folder(resource_dir: String, instance_load_type: InstantiationType = InstantiationType.REGISTER_RESOURCE) -> void:
	if !DirAccess.dir_exists_absolute(resource_dir):
		return
	
	var dir := DirAccess.open(resource_dir)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension() == "gd":
			var id: String = file_name.get_basename() 
			var full_path: String = resource_dir.path_join(file_name)

			var script_resource: GDScript = load(full_path) as GDScript

			if !script_resource:
				continue
			else:
				if instance_load_type == InstantiationType.REGISTER_RESOURCE:
					register_object(id, script_resource)
				elif instance_load_type == InstantiationType.INSTANCE_AS_CLASS:
					var instance: Object = script_resource.new()
					if instance:
						register_object(id, instance)
		file_name = dir.get_next()
	dir.list_dir_end()


func get_registries() -> Array:
	return _map.keys()

func contains(name: String) -> bool:
	return _map.has(name)
