class_name Server extends Node

@onready var space_manager: ServerSpaceManager = $ServerSpaceManager
@onready var network_manager: NetworkServerManager = $NetworkServerManager
@onready var save_file_manager: SaveFileManager = $SaveFileManager

func _ready() -> void:
	initialize_managers()
	# Open my save
	save_file_manager.new_save("my_save")
	
	# create a space
	_load_world("bodega_bay")
	_load_world("sunny_dunes")
	
	# Spin up the server
	network_manager.start_server(save_file_manager.config.address, save_file_manager.config.port)
	network_manager.packet_received.connect(_on_packet_received)

func initialize_managers() -> void:
	space_manager._sent_data.connect(network_manager.network_bus.send_data)

func _on_packet_received(type: String, data: Array, conn: NetworkServerManager.Connection) -> void:
	# NOTE: Noisy ah print
	#print("[SERVER] received from [%s] -> [%s]: %s" % [type, data, conn.id])
	var handler := PacketHandlerServer.get_handler(type)
	if handler:
		handler.run(self, data, conn)

# TODO: Temp only. need proper way of dynamically loading worlds when needed
func _load_world(map_id: String) -> void:
	var map_area := preload("res://server/spaces/space_map.gd").new()
	map_area.load_from_json(save_file_manager.load_map_state(map_id))
	space_manager.add_space(map_area)
	space_manager._map_name_to_id[map_id] = map_area.id
