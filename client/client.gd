class_name Client extends Node2D

var network_layer: NetworkLayer

func _ready() -> void:
	# Register client resource
	CommonRegistryService.register_client_resource()
	
	_start_singleplayer_game()
	network_layer.connect_to_server({"username": "DefaultUsername!"})

func _start_singleplayer_game() -> void:
	network_layer = IntegratedNetworkLayer.new()
	add_child(network_layer)
	
	var server := Server.new()
	add_child(server)
	@warning_ignore("unsafe_method_access")
	network_layer.attach_server(server)

func _join_game() -> void:
	network_layer = ConnectionNetworkLayer.new()
	add_child(network_layer)
