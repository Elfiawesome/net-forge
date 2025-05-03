class_name Server extends Node

@onready var space_manager: ServerSpaceManager = $ServerSpaceManager
@onready var network_manager: NetworkServerManager = $NetworkServerManager
@onready var save_file_manager: SaveFileManager = $SaveFileManager

func _ready() -> void:
	# Open my save
	save_file_manager.new_save("my_save")
	
	# Spin up the server
	network_manager.start_server(save_file_manager.config.address, save_file_manager.config.port)
	network_manager.packet_received.connect(_on_packet_received)
	
	# create a space
	var map_area_1 := preload("res://server/spaces/space_map.gd").new()
	map_area_1.load_from_json(save_file_manager.load_map_state("bodega_bay"))
	
	#var map_area_2 := preload("res://server/spaces/space_map.gd").new()
	
	
	#space_manager.add_space(map_area_1)
	#space_manager.add_space(map_area_2)


func _on_packet_received(type: String, data: Array, conn: NetworkServerManager.Connection) -> void:
	print("[SERVER] received from [%s] -> [%s]: %s" % [type, data, conn.id])
	var handler := PacketHandlerServer.get_handler(type)
	if handler:
		handler.run(self, data, conn)
