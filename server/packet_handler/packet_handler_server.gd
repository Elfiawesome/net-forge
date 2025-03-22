class_name PacketHandlerServer extends RefCounted

static var REGISTRY := RegistrySimple.new()

static func register() -> void:
	REGISTRY.register_object("ConnectionRequest", preload("res://server/packet_handler/connection_request.gd").new())
	REGISTRY.register_object("ConnectionLost", preload("res://server/packet_handler/connection_lost.gd").new())


static func get_handler(packet_type: String) -> PacketHandlerServer:
	return REGISTRY.get_object(packet_type)

func run(_server: Server, _client: Server.Client, _data: Array) -> void: pass
