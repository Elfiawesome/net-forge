class_name RemoteWorldService extends Node

var _worlds: Dictionary[String, RemoteWorld] = {}

func get_world(world_type: String) -> RemoteWorld:
	if world_type in _worlds:
		return _worlds[world_type]
	else:
		return create_world(world_type)

func create_world(world_type: String = "remote_world") -> RemoteWorld:
	if world_type in _worlds:
		printerr("RemoteWorldService can't create a duplicate world type %s" % world_type)
		return
	var script: GDScript = Registries.get_resource(Registries.REMOTE_WORLD, world_type)
	var world: RemoteWorld
	if !script:
		world = RemoteWorld.new()
	else:
		world = script.new()
	# Add world
	_worlds[world_type] = world
	add_child(world)
	world.world_type = world_type
	
	world.name = world_type
	# TODO: Check disk if existing world save and load it onto this world object
	return world

func destroy_world(world_type: String) -> void:
	if !(world_type in _worlds):
		printerr("RemoteWorldService can't destroy a world that doesn't exist: " % world_type)
		return
	var world := _worlds[world_type]
	# TODO: Save world to disk
	world.queue_free()

func _generate_world_id() -> String:
	return str(Time.get_ticks_usec()).sha256_text()
