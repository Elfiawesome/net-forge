class_name SpaceManager extends Node

var bus: SpaceBus
var server_bus: Server.ServerBus

var spaces: Dictionary[String, ServerSpace] = {}
var _space_type_handlers: Dictionary[String, SpaceTypeHandler] = {}
var _client_to_spaces: Dictionary[String, String] = {} # [client_id, space_id] Map of clients to their assigned spaces

func _ready() -> void:
	# Add a default space type handler which managers space base class
	add_type_handler("space", SpaceTypeHandler.new())

# Register a type handler so that we can create specific type spaces
func add_type_handler(space_type_name: String, space_type_handler: SpaceTypeHandler) -> void:
	if space_type_name in _space_type_handlers: return
	_space_type_handlers[space_type_name] = space_type_handler

# Add a custom space
func add_space(space_type: String) -> ServerSpace:
	if !_space_type_handlers.has(space_type):
		printerr("[SpaceManager] Tried to create a invalid space type of %s" % space_type)
		return
	var space := _space_type_handlers[space_type].create_space()
	if space:
		var space_id := UUID.v4()
		space.id = space_id
		space.space_type = space_type
		space.server_bus = server_bus
		spaces[space_id] = space
		space.name = space_type + "_" + space_id
		add_child(space)
		return space
	return

func remove_space(space_id: String) -> void:
	if space_id in spaces:
		var space := spaces[space_id]
		
		var space_type := space.space_type
		if space_type in _space_type_handlers:
			_space_type_handlers[space_type].remove_space(space_id)

		for client_id in space.connected_clients:
			deassign_client_from_space(client_id)
		spaces[space_id].free()
		spaces.erase(space_id)

func assign_client_to_space(client_id: String, space_id: String) -> void:
	if !(space_id in spaces): return
	if client_id in _client_to_spaces:
		deassign_client_from_space(client_id)
	
	spaces[space_id].client_joined(client_id)
	_client_to_spaces[client_id] = space_id

func deassign_client_from_space(client_id: String) -> void:
	if !(client_id in _client_to_spaces): return
	var space_id := _client_to_spaces[client_id]
	if !(space_id in spaces): return
	spaces[space_id].client_left(client_id)
	_client_to_spaces.erase(client_id)

# Use this if you want to have a top level overview of all the specifics of a space type. 
class SpaceTypeHandler:
	func _init() -> void:
		pass
	
	func create_space() -> ServerSpace:
		return ServerSpace.new()

	func remove_space(_space_id: String) -> void:
		pass

class SpaceBus:
	pass
