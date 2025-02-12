class_name NetworkLib extends Object

class NetworkServer extends Node:
	signal client_request_connection(temp_id: String, user_data: Dictionary)
	signal client_lost_connection(client_id: String, close_connection_msg: CloseConnectionMsg)
	signal data_received(client_id: String, data: Variant)
	
	signal server_start_success()
	signal server_start_failed(err: int)
	
	var server: TCPServer
	var client_datas: Dictionary[String, ClientDataServer] = {}
	var address: String
	var port: int
	
	var _waiting_clients: Dictionary[String, ClientDataServer] = {}
	var _waiting_client_index: int = 1
	
	func _init(connecting_address: String = "127.0.0.1", connecting_port:int = 3115) -> void:
		# Setting address and port for server
		address = connecting_address
		port = connecting_port
	
	func start_server() -> void:
		# Creating Server
		server = TCPServer.new()
		var err := server.listen(port, address)
		if err == OK:
			server_start_success.emit()
		else:
			server_start_failed.emit(err)
	
	func _process(_delta: float) -> void:
		if server != null:
			if server.is_connection_available():
				var connection := server.take_connection()
				var client_data := ClientDataServer.new()
				client_data.peer = PacketPeerStream.new()
				client_data.peer.stream_peer = connection
				client_data.connection = connection
				
				client_data.data_received.connect(_on_client_waiting_data_received)
				client_data.connection_lost.connect(_on_client_waiting_connection_lost)
				client_data.id = str(_waiting_client_index)
				_waiting_clients[client_data.id] = client_data
				_waiting_client_index += 1
		
		for _id in _waiting_clients:
			_waiting_clients[_id].update()
		for _id in client_datas:
			client_datas[_id].update()
	
	func _on_client_waiting_data_received(waiting_client_id: String, data: Variant) -> void:
		var client_data := _waiting_clients[waiting_client_id]
		client_request_connection.emit(waiting_client_id, data)
	
	func _on_client_waiting_connection_lost(waiting_client_id: String, _close_connection_msg: CloseConnectionMsg) -> void:
		_waiting_clients.erase(waiting_client_id)
	
	func approve_waiting_client(waiting_client_id: String, client_id: String) -> void:
		if client_id in client_datas:
			printerr("NetworkServer already has this client id connected %s" % client_id)
			return
		var client_data := _waiting_clients[waiting_client_id]
		# Disconnect old _on_client "waiting" functions
		client_data.data_received.disconnect(_on_client_waiting_data_received)
		client_data.connection_lost.disconnect(_on_client_waiting_connection_lost)
		# Reconnect to the normal _on_client functions instead
		client_data.data_received.connect(_on_client_data_received)
		client_data.connection_lost.connect(_on_client_connection_lost)
		# Update the id for referencing later
		client_data.id = client_id
		# Add the client_data to the client_datas and remove from the old waiting_clients
		_waiting_clients.erase(waiting_client_id)
		client_datas[client_id] = client_data
	
	func reject_waiting_client(waiting_client_id: String, error_reason: CloseConnectionMsg = CloseConnectionMsg.new("Declined to connect to server", "")) -> void:
		var client_data := _waiting_clients[waiting_client_id]
		client_data.close_connection(error_reason)
	
	func _on_client_data_received(client_id: String, data: Variant) -> void:
		data_received.emit(client_id, data)
	
	func _on_client_connection_lost(client_id: String, close_connection_msg: CloseConnectionMsg) -> void:
		client_lost_connection.emit(client_id, close_connection_msg)
		if client_datas.has(client_id):
			client_datas.erase(client_id)
	
	func send_data(client_id: String, data: Variant) -> void:
		if client_datas.has(client_id):
			client_datas[client_id].peer.put_var(data)
	
	func kick_client(client_id: String, kick_title: String, kick_reason: String, authorizer_user: String) -> void:
		if client_datas.has(client_id):
			var client_data := client_datas[client_id]
			client_data.close_connection(CloseConnectionMsg.new(kick_title, "kicked by %s for %s" %[authorizer_user, kick_reason]))

class NetworkClient extends Node:
	signal data_received(data: Variant)
	signal connection_lost(close_connection_msg: CloseConnectionMsg)
	
	var client_data: ClientDataClient
	var address: String
	var port: int
	
	func _init(conecting_address: String = "127.0.0.1", connecting_port: int = 3115) -> void:
		# Setting address and port for connection
		address = conecting_address
		port = connecting_port
	
	func connect_to_server(user_data: Dictionary) -> void:
		client_data = ClientDataClient.new()
		client_data.connection = StreamPeerTCP.new()
		client_data.connection.connect_to_host(address, port)
		client_data.peer = PacketPeerStream.new()
		client_data.peer.stream_peer = client_data.connection
		
		client_data.connected.connect(_on_client_connected.bind(user_data))
		client_data.connection_lost.connect(_on_client_connection_lost)
		client_data.data_received.connect(_on_client_data_received)
	
	func _process(_delta: float) -> void:
		if !client_data: return
		client_data.update()
	
	func _on_client_connected(user_data: Dictionary) -> void:
		client_data.peer.put_var(user_data)
	func _on_client_connection_lost(close_connection_msg: CloseConnectionMsg) -> void:
		connection_lost.emit(close_connection_msg)
	func _on_client_data_received(data: Variant) -> void:
		data_received.emit(data)
	
	func send_data(data: Variant) -> void:
		if client_data:
			client_data.peer.put_var(data)

class ClientData extends Node:
	var peer: PacketPeerStream
	var connection: StreamPeerTCP
	
	func update() -> void: pass
	func close_connection(_close_connection_msg: CloseConnectionMsg) -> void: pass

class ClientDataServer extends ClientData:
	signal connection_lost(client_id: String, close_connection_msg: CloseConnectionMsg)
	signal data_received(client_id: String, data: Variant)
	
	var id: String
	
	func update() -> void:
		connection.poll()
		var status := connection.get_status()
		if status == StreamPeerTCP.STATUS_ERROR or status == StreamPeerTCP.STATUS_NONE:
			close_connection(CloseConnectionMsg.new("Disconnected from server", ""))
		
		while(peer.get_available_packet_count() > 0):
			data_received.emit(id, peer.get_var())
	
	func close_connection(close_connection_msg: CloseConnectionMsg) -> void:
		connection_lost.emit(id, close_connection_msg)
		connection.disconnect_from_host()
		queue_free()

class ClientDataClient extends ClientData:
	signal connection_lost(close_connection_msg: CloseConnectionMsg)
	signal data_received(data: Variant)
	signal connected()
	
	var _has_connected := false
	
	func update() -> void:
		connection.poll()
		var status := connection.get_status()
		if status == StreamPeerTCP.STATUS_CONNECTED:
			if !_has_connected:
				_has_connected = true
				connected.emit()
		elif status == StreamPeerTCP.STATUS_CONNECTING:
			pass # Do nothing
		elif status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
			close_connection(CloseConnectionMsg.new("Disconnected from server", ""))
		
		while(peer.get_available_packet_count() > 0):
			data_received.emit(peer.get_var())
	
	func close_connection(close_connection_msg: CloseConnectionMsg) -> void:
		connection_lost.emit(close_connection_msg)
		_has_connected = false
		connection.disconnect_from_host()
		queue_free()

class CloseConnectionMsg:
	var title: String
	var description: String
	
	func _init(title_: String, description_: String) -> void:
		title = title_
		description = description_
	
	func serialize() -> Dictionary:
		return {
			"type": "close_connection_msg",
			"title": title,
			"description": description
		}
	func deserialize(data: Dictionary) -> void:
		title = data.get("title", "")
		description = data.get("description", "")
