class_name RegistrySimple extends RefCounted

var _map: Dictionary[String, Object] = {}

func _init() -> void:
	pass

func get_object(name: String) -> Object:
	return _map.get(name)

func register_object(name: String, object: Variant) -> void:
	print("Registering '%s'" % name)
	_map.set(name, object)

func get_registries() -> Array:
	return _map.keys()

func contains(name: String) -> bool:
	return _map.has(name)
