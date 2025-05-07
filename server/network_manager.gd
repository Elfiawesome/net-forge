class_name NetworkServerManager extends Node

signal packet_received(_type: String, _data: Array, _conn: Connection)

var _tcp_server: TCPServer
var bus: NetworkBus
var connections: Dictionary[String, Connection] = {}

func _ready() -> void:
	bus = NetworkBus.new(self)

func _process(_delta: float) -> void:
	if !_tcp_server: return
	if _tcp_server.is_connection_available():
		var connection := TCPConnection.new(_tcp_server.take_connection())
		attach_connection(connection)

func start_server(address: String, port: int) -> void:
	_tcp_server = TCPServer.new()
	_tcp_server.listen(port, address)
	print("[SERVER] Listening on %s:%d" % [address, port])

func attach_connection(connection: Connection) -> void:
	connection.packet_received.connect(_on_packet_received.bind(connection))
	add_child(connection)

func _on_packet_received(type: String, data: Array, conn: Connection) -> void:
	packet_received.emit(type, data, conn)

class Connection extends Node:
	signal packet_received(type: String, data: Array)

	var id: String
	var _timeout_timer: Timer
	
	func _ready() -> void:
		_timeout_timer = Timer.new()
		add_child(_timeout_timer)
		_timeout_timer.one_shot = true
		_timeout_timer.timeout.connect(
			func() -> void: 
				# TODO: Implement timeout handling (like force disconnect or something)
				pass
		)
	
	func force_disconnect(disconnect_reason: String = "Unknown disconnected by server.") -> void:
		var disconnect_data := {"reason": disconnect_reason}
		send_data("force_disconnect", [disconnect_data]) # Tell disconnecting client
		packet_received.emit("connection_lost", [disconnect_data]) # Tell server that client disconnected
		queue_free()
	
	func send_data(_type: String, _data: Array = []) -> void: pass

class IntegratedConnection extends Connection:
	# TODO: Implement integrated connection
	pass

class TCPConnection extends Connection:
	var stream_peer: StreamPeerTCP
	var packet_peer: PacketPeerStream
	
	func _init(stream_peer_: StreamPeerTCP) -> void:
		stream_peer = stream_peer_
		packet_peer = PacketPeerStream.new()
		packet_peer.set_stream_peer(stream_peer)
		send_data("init_request")
	
	func _process(_delta: float) -> void:
		stream_peer.poll()

		var status := stream_peer.get_status()
		if (status == stream_peer.Status.STATUS_ERROR) or (status == stream_peer.Status.STATUS_NONE):
			force_disconnect("Unkown disconnected by player.")
		
		while (packet_peer.get_available_packet_count() > 0):
			var data: Variant = packet_peer.get_var()
			if data is Array and data.size() == 2:
				var type: String = data[0]
				var data_: Array = data[1]
				packet_received.emit(type, data_)

	func force_disconnect(disconnect_reason: String = "Unknown disconnected by server.") -> void:
		super.force_disconnect(disconnect_reason)
		stream_peer.disconnect_from_host()
	
	func send_data(type: String, data: Array = []) -> void:
		stream_peer.poll()
		stream_peer.put_var([type, data])

class NetworkBus:
	var _network_server_manager: NetworkServerManager
	
	func _init(network_server_manager_: NetworkServerManager) -> void:
		_network_server_manager = network_server_manager_

	func send_data(client_id: String, type: String, data: Array = []) -> void:
		if _network_server_manager.connections.has(client_id):
			_network_server_manager.connections[client_id].send_data(type, data)
	
	func broadcast_data(type: String, data: Array = []) -> void:
		for client_id: String in _network_server_manager.connections:
			_network_server_manager.connections[client_id].send_data(type, data)
	
	func broadcast_data_specific(client_list: Array, type: String, data: Array = [], is_exclude: bool = false) -> void:
		if !is_exclude:
			for client_id: String in client_list:
				send_data(client_id, type, data)
		else:
			for client_id: String in _network_server_manager.connections:
				if !(client_id in client_list):
					send_data(client_id, type, data)
