class_name NetworkLayer extends Node

var port := 3115
var address := "127.0.0.1"

@warning_ignore("unused_signal")
signal data_received(packet_name: String, packet_data: Dictionary)

var my_player_id: String

func connect_to_server(_user_data: Dictionary) -> void:
	pass

func send_data(_packet_name: String, _packet_data: Dictionary) -> void:
	pass
