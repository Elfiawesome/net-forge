class_name Server extends Node

@onready var room_server_manager: RoomServerManager = $RoomServerManager
@onready var network_server_manager: NetworkServerManager = $NetworkServerManager
@onready var save_file_manager: SaveFileManager = $SaveFileManager

func _ready() -> void:
	save_file_manager.new_save("my_save")
	
	network_server_manager.start_server(save_file_manager.config.address, save_file_manager.config.port)
	network_server_manager.packet_received.connect(_on_packet_received)

func _on_packet_received(type: String, data: Array, conn: NetworkServerManager.Connection) -> void:
	print("[SERVER] received from [%s] -> [%s]: %s" % [type, data, conn.id])
	var handler := PacketHandlerServer.get_handler(type)
	if handler:
		handler.run(self, data, conn)
