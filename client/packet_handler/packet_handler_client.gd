class_name PacketHandlerClient extends RefCounted

static var REGISTRY := RegistrySimple.new()

static func register() -> void:
	pass


static func get_handler(packet_type: String) -> PacketHandlerClient:
	return REGISTRY.get_object(packet_type)

# TODO: Needs to have client/gamesessioniin here
func run() -> void: pass
