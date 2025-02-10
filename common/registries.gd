extends Node

class CategoryRegistry:
	var resources: Dictionary[String, Resource] = {}
	var instances: Dictionary[String, Object] = {}

# Default registry categories
const CLIENT_BOUND_PACKET := "client_bound_packet"
const LOCAL_WORLD := "local_world"
const LOCAL_ENTITY := "local_entity"
const SERVER_BOUND_PACKET := "server_bound_packet"
const REMOTE_WORLD := "remote_world"
const REMOTE_ENTITY := "remote_world"

# Main registry storage
var registries: Dictionary[String, CategoryRegistry] = {}

func register_resource(category: String, key: String, resource: Resource) -> void:
	_ensure_category_exists(category)
	registries[category].resources[key] = resource

func register_script_instance(category: String, key: String, resource: GDScript) -> void:
	_ensure_category_exists(category)
	registries[category].instances[key] = resource.new()

func register_instance(category: String, key: String, instance: Object) -> void:
	_ensure_category_exists(category)
	registries[category].instances[key] = instance

func get_resource(category: String, key: String) -> Resource:
	if not registries.has(category):
		push_error("Category not found: ", category)
		return null
		
	return registries[category].resources.get(key, null)

func get_instance(category: String, key: String) -> Object:
	if not registries.has(category):
		push_error("Category not found: ", category)
		return null
		
	return registries[category].instances.get(key, null)

func _ensure_category_exists(category: String) -> void:
	if not registries.has(category):
		registries[category] = CategoryRegistry.new()
