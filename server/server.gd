class_name Server extends Node

# Initialize all the managers
@onready var network_manager: NetworkServerManager = $NetworkManager
@onready var persistance_manager: PersistanceManager = $PersistanceManager
@onready var space_manager: SpaceManager = $SpaceManager
@onready var player_states_manager: PlayerStatesManager = $PlayerStatesManager
##Global Server Manager Bus
var server_bus: ServerBus

const SPACE_TYPES = {
	DEFAULT_SPACE = "space",
	MAP = "map",
	BATTLE = "battle"
}

func _ready() -> void:
	# Initialize ServerBus
	server_bus = ServerBus.new(
		network_manager.bus, 
		persistance_manager.bus, 
		space_manager.bus, 
		player_states_manager.bus
	)
	# Pass the ServerBus to all required managers
	space_manager.server_bus = server_bus

	# Load server config files as default
	persistance_manager.new_save("my-save")
	
	# Spin up the network server and hook it up to the packet handler
	network_manager.start_server(
		server_bus.persitance.get_server_config().address,
		server_bus.persitance.get_server_config().port
	)
	network_manager.packet_received.connect(_on_packet_received)

func _on_packet_received(type: String, data: Array, conn: NetworkServerManager.Connection) -> void:
	print("[SERVER] received from [%s] -> [%s]: %s" % [type, data, conn.id])
	var handler := PacketHandlerServer.get_handler(type)
	if handler:
		handler.run(self, data, conn)

func shutdown() -> void:
	# Simulate disconnection on all clients 
	# NOTE: Apparently you cant just anyhow delete keys in a  dictionary while in a loop cuz it didnt work here
	for client_id: String in network_manager.connections.keys():
		network_manager.connections[client_id].force_disconnect("Server Shutdown...")
	
	network_manager._tcp_server.stop()

class ServerBus extends RefCounted:
	var network: NetworkServerManager.NetworkBus
	var persitance: PersistanceManager.PersistanceBus
	var space: SpaceManager.SpaceBus
	var player_states: PlayerStatesManager.PlayerStatesBus

	func _init(network_: NetworkServerManager.NetworkBus, persitance_: PersistanceManager.PersistanceBus, space_: SpaceManager.SpaceBus, player_states_: PlayerStatesManager.PlayerStatesBus) -> void:
		network = network_
		persitance = persitance_
		space = space_
		player_states = player_states_
