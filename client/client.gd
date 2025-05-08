class_name Client extends Node2D

@onready var network_client_manager: NetworkClientManager = $NetworkClientManager
@onready var top_overlay: ClientTopOverlay = $TopOverlay

var game_config: ServerConfig

func _ready() -> void:
	top_overlay.set_overlay_message("Loading into server...")
	top_overlay.display()

func connect_to_server(username: String) -> void:
	# Connect to server
	if !network_client_manager.connection:
		printerr("[Client] No Connection Object was specified")
		return
	network_client_manager.connection.packet_received.connect(_on_packet_received)
	network_client_manager.connection.connect_to_server({
		"username": username,
	})
	network_client_manager.add_child(network_client_manager.connection)

func _on_packet_received(type: String, data: Array) -> void:
	var handler := PacketHandlerClient.get_handler(type)
	if handler:
		handler.run(self, data)
