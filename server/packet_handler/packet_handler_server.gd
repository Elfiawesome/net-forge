class_name PacketHandlerServer extends RefCounted

static var REGISTRY := RegistrySimple.new()

static func register() -> void:
	REGISTRY.register_all_objects_in_folder("res://server/packet_handler/global/", REGISTRY.InstantiationType.INSTANCE_AS_CLASS)
	REGISTRY.register_all_objects_in_folder("res://server/packet_handler/space/map/", REGISTRY.InstantiationType.INSTANCE_AS_CLASS)

static func get_handler(handler_type: String) -> PacketHandlerServer:
	var handler := REGISTRY.get_object(handler_type)
	if handler == null:
		printerr("[PacketHandlerServer] Handler not found: %s" % handler_type)
		return null
	return handler

func run(_server: Server, _data: Array, _conn: NetworkServerManager.Connection) -> void:
	pass