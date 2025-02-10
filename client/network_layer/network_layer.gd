class_name NetworkLayer extends Node

var port := 3115
var address := "127.0.0.1"

@warning_ignore("unused_signal")
signal data_received(_packet_name: String, _packet_data: Dictionary)

var my_player_id: String

## Connects to a server. Specific implementation depends on the derived class
## (IntegratedNetworkLayer vs. ConnectionNetworkLayer).
func connect_to_server(_user_data: Dictionary) -> void:
	pass

## Sends data to the server or other clients.  Implementation depends on the derived class.
func send_data(_packet_name: String, _packet_data: Dictionary) -> void:
	pass
