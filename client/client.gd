class_name Client extends Node2D

var network_layer: NetworkLayer
var loaded_world: LocalWorld

func _ready() -> void:
	# Register client resource
	CommonRegistryService.register_client_resource()
	
	var instance_num := 0
	if OS.get_cmdline_args().size() > 1:
		instance_num = int(OS.get_cmdline_args()[1])
		get_window().title = "Instance %s" % instance_num
		if instance_num == 0:
			_start_singleplayer_game()
		else:
			_join_game()
	else:
		_start_singleplayer_game()
	network_layer.data_received.connect(_on_data_received)
	network_layer.connect_to_server({"username": "DefaultUsername_%s" % instance_num})

func _start_singleplayer_game() -> void:
	network_layer = IntegratedNetworkLayer.new()
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
