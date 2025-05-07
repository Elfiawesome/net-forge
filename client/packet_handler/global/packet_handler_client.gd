class_name PacketHandlerClient extends RefCounted

static var REGISTRY := RegistrySimple.new()

static func register() -> void:
	REGISTRY.register_all_objects_in_folder("res://client/packet_handler/global/", REGISTRY.InstantiationType.INSTANCE_AS_CLASS)
	REGISTRY.register_all_objects_in_folder("res://client/packet_handler/space/map/", REGISTRY.InstantiationType.INSTANCE_AS_CLASS)

static func get_handler(handler_type: String) -> PacketHandlerClient:
	var handler := REGISTRY.get_object(handler_type)
	if handler == null:
		printerr("[PacketHandlerClient] Handler not found: %s" % handler_type)
		return null
	return handler

func run(_client: Client, _data: Array) -> void:
	pass
