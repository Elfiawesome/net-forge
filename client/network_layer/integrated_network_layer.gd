class_name IntegratedNetworkLayer extends NetworkLayer

var server: Server
var network_server: NetworkLib.NetworkServer

func _ready() -> void:
	network_server = NetworkLib.NetworkServer.new(address, port)
	network_server.client_request_connection.connect(
		func(temp_id: String, user_data: Dictionary) -> void:
			if user_data.has("username"):
				var player_id := _generate_player_id(user_data["username"])
				network_server.approve_waiting_client(temp_id, player_id)
				server.player_request_connection(player_id, user_data)
			else:
				network_server.reject_waiting_client(temp_id, NetworkLib.CloseConnectionMsg.new("No username given", "requested user_data is missing username"))
	)
	network_server.client_lost_connection.connect(
		func(player_id: String, _close_connection_msg: NetworkLib.CloseConnectionMsg) -> void:
			server.player_disconnect(player_id)
	)
	network_server.data_received.connect(
		func(player_id: String, raw_data: Variant) -> void:
			if raw_data is Dictionary:
				var data := raw_data as Dictionary
				var _time: int = data.get("time", -1)
				var packet: Dictionary = data.get("packet", {})
				var packet_name: String = packet.get("packet_name", "")
				var packet_data: Dictionary = packet.get("packet_data", {})
				
				server.run_packet(player_id, packet_name, packet_data)
	)
	add_child(network_server)
	network_server.start_server()
	

## When host player wants to DIRECTLY connect to the server
func connect_to_server(user_data: Dictionary) -> void:
	# Check if user data is even valid
	if !user_data.has("username"):
		printerr("Host connection request to network layer has no username")
		return
	var username: String = user_data["username"]
	my_player_id = _generate_player_id(username)
	
	# Finally request it to the server
	server.player_request_connection(my_player_id, user_data)

## (Host -> Server)
func send_data(packet_name: String, packet_data: Dictionary) -> void:
	server.run_packet(my_player_id, packet_name, packet_data)

func attach_server(server_: Server) -> void:
	server = server_
	server.data_send.connect(_on_data_received)
	server.kick_player.connect(_on_kick_player)

## (Server -> Client)
func _on_data_received(player_id: String, packet_name: String, packet_data: Dictionary) -> void:
	if player_id == my_player_id:
		data_received.emit(packet_name, packet_data)
	else:
		network_server.send_data(player_id, {
			"time": Time.get_ticks_usec(),
			"packet": {
				"packet_name": packet_name,
				"packet_data": packet_data,
			}
		})

## (Server -> Client)
func _on_kick_player(_player_id: String, _reason: String, _authorizer: String) -> void:
	pass #TODO: Idk

func _generate_player_id(username: String) -> String:
	return username # For sake of simplicity
	#return username.sha256_text()
