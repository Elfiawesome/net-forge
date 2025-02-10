class_name Client extends Node2D

var network_layer: NetworkLayer

func _ready() -> void:
	# Register client resource
	CommonRegistryService.register_client_resource()
	
	_start_singleplayer_game()
	network_layer.connect_to_server({"username": "DefaultUsername!"})

func _start_singleplayer_game() -> void:
	network_layer = IntegratedNetworkLayer.new()
	network_layer.data_received.connect(_on_data_received)
	add_child(network_layer)
	
	var server := preload("res://server/server.tscn").instantiate()
	add_child(server)
	@warning_ignore("unsafe_method_access")
	network_layer.attach_server(server)

func _join_game() -> void:
	network_layer = ConnectionNetworkLayer.new()
	add_child(network_layer)

func _on_data_received(packet_name: String, packet_data: Dictionary) -> void:
	var packet: ClientBoundPacket = Registries.get_instance(Registries.CLIENT_BOUND_PACKET, packet_name)
	if !packet:
		printerr("Client can't get packet %s" % packet_name)
		return
	packet.run(self, packet_data)
