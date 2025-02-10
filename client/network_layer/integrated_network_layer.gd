class_name IntegratedNetworkLayer extends NetworkLayer

var server: Server

## When host player wants to DIRECTLY connect to the server
func connect_to_server(user_data: Dictionary) -> void:
	# Check if user data is even valid
	if !user_data.has("username"):
		return
	var username: String = user_data["username"]
	my_player_id = _generate_player_id(username)
	
	# Finally request it to the server
	server.player_request_connection(my_player_id, user_data)

## (Client -> Server)
func send_data(_packet_name: String, _packet_data: Dictionary) -> void:
	pass

func attach_server(server_: Server) -> void:
	server = server_
	server.data_send.connect(_on_data_received)
	server.kick_player.connect(_on_kick_player)

## (Server -> Client)
func _on_data_received(player_id: String, packet_name: String, packet_data: Dictionary) -> void:
	if player_id == my_player_id:
		data_received.emit(packet_name, packet_data)
	else:
		# Send over network to other players
		pass

## (Server -> Client)
func _on_kick_player(_player_id: String, _reason: String, _authorizer: String) -> void:
	pass #TODO: Idk

func _generate_player_id(username: String) -> String:
	return username # For sake of simplicity
	#return username.sha256_text()
