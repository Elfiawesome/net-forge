class_name Client extends Node2D

@onready var network_client_manager: NetworkClientManager = $NetworkClientManager
@onready var top_overlay: ClientTopOverlay = $TopOverlay

const MAP_SCENE := preload("res://client/map/local_map.tscn")

var game_config: PersistanceManager.ServerConfig
var map: LocalMap

func _ready() -> void:
	top_overlay.set_overlay_message("Loading into server...")
	top_overlay.display()

func connect_to_server(address: String, port: int, username: String) -> void:
	# Connect to server
	network_client_manager.connection = NetworkClientManager.TCPConnection.new()
	network_client_manager.connection.packet_received.connect(_on_packet_received)
	network_client_manager.connection.set_target(address, port).connect_to_server({
		"username": username,
	})
	network_client_manager.add_child(network_client_manager.connection)

func set_map(new_map: LocalMap) -> void:
	if map != null:
		map.queue_free()
	map = new_map
	new_map.connection = network_client_manager.connection
	add_child(new_map)

func _on_packet_received(type: String, data: Array) -> void:
	var handler := PacketHandlerClient.get_handler(type)
	if handler:
		handler.run(self, data)
