class_name NetworkClientManager extends Node

var connection: Connection

class Connection extends Node:
	@warning_ignore("unused_signal")
	signal packet_received(_type: String, _data: Array)
	
	var _request_data: Dictionary
	
	func connect_to_server(request_data: Dictionary = {}) -> void:
		_request_data = request_data
	func send_data(_type: String, _data: Array = []) -> void: pass

class IntegratedConnection extends Connection:
	pass

class TCPConnection extends Connection:
	var address: String
	var port: int

	var stream_peer: StreamPeerTCP
	var packet_peer: PacketPeerStream
	
	func set_target(address_: String, port_: int) -> TCPConnection:
		# TODO: Alternatively, we could do this in the constructor
		address = address_
		port = port_
		return self

	func connect_to_server(request_data: Dictionary = {}) -> void:
		super.connect_to_server(request_data)
		stream_peer = StreamPeerTCP.new()
		packet_peer = PacketPeerStream.new()
		
		stream_peer.connect_to_host(address, port)
		packet_peer.stream_peer = stream_peer
		
	
	func _process(_delta: float) -> void:
		if !stream_peer: return
		stream_peer.poll()

		var status := stream_peer.get_status()
		if (status == stream_peer.Status.STATUS_ERROR) or (status == stream_peer.Status.STATUS_NONE):
			disconnect_from_server()
		
		while (packet_peer.get_available_packet_count() > 0):
			var data: Variant = packet_peer.get_var()
			if data is Array and data.size() == 2:
				var type: String = data[0]
				var data_: Array = data[1]
				packet_received.emit(type, data_)
	
	func disconnect_from_server(disconnect_reason: String = "Unknown disconnected by server.") -> void:
		var disconnect_data := {"reason": disconnect_reason}
		packet_received.emit("force_disconnect", [disconnect_data])
		leave_server()
	
	func leave_server() -> void:
		stream_peer.disconnect_from_host()
		# TODO: this is to prevent errors. RN we directly inject the entire Connection object into various systems. Shoud'nt raelly do that :/
		# queue_free()

	func send_data(type: String, data: Array = []) -> void:
		if stream_peer:
			stream_peer.poll()
			stream_peer.put_var([type, data])
