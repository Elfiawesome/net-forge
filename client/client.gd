class_name Client extends Node2D

@onready var network_client_manager: NetworkClientManager = $NetworkClientManager

func _ready() -> void:
	network_client_manager.connection = NetworkClientManager.TCPConnection.new()
	network_client_manager.connection.set_target("127.0.0.1", 3115).connect_to_server({
		"username": Global.username
	})
	network_client_manager.add_child(network_client_manager.connection)

	network_client_manager.connection.packet_received.connect(_on_packet_received)

func _on_packet_received(type: String, data: Array) -> void:
	print("[CLIENT] received [%s] -> %s" % [type, data])
	var handler := PacketHandlerClient.get_handler(type)
	if handler:
		handler.run(self, data)
