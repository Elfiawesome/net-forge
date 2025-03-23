class_name Server extends Node

var tcp_server: TCPServer

var player_manager := preload("res://server/player_manager.gd").new()
var clients: Dictionary[String, Client] = {}

func _ready() -> void:
	var port := 3115
	var address := "127.0.0.1"
	tcp_server = TCPServer.new()
	tcp_server.listen(port, address)

func _process(_delta: float) -> void:
	if tcp_server.is_connection_available():
		var client := Client.new(tcp_server.take_connection())
		client.packet_received.connect(_on_client_handle_data.bind(client))
		add_child(client)

func _on_client_handle_data(type: String, data: Array, client: Client) -> void:
	print("Server packet: " + type + " -> " +str(data) + " {" + str(client.id) + "}")
	var handler := PacketHandlerServer.get_handler(type)
	if !handler: return
	handler.run(self, client, data)

class Client extends Node:
	signal packet_received(type: String, data: Array)
	
	var stream_peer: StreamPeerTCP
	var packet_peer: PacketPeerStream
	var state: State = State.NONE
	var id: String
	
	enum State {
		NONE = 0,
		REQUEST,
		PLAY
	}
	
	func _init(connection: StreamPeerTCP) -> void:
		stream_peer = connection
		packet_peer = PacketPeerStream.new()
		packet_peer.stream_peer = stream_peer
	
	func _ready() -> void:
		var t := Timer.new()
		add_child(t)
		t.start(3)
		t.one_shot = true
		t.timeout.connect(
			func() -> void:
				t.queue_free()
				if state != State.PLAY:
					force_disconnect("Timeout. No connection request was made by client.")
		)
	
	func force_disconnect(disconnect_reason: String = "Unknown disconnected by server.") -> void:
		var disconnect_data := {"reason":disconnect_reason}
		stream_peer.put_var(["ForceDisconnect", disconnect_data])
		stream_peer.disconnect_from_host()
		packet_received.emit("ConnectionLost", [disconnect_data])
		queue_free()
	
	func _process(_delta: float) -> void:
		stream_peer.poll()
		
		var status := stream_peer.get_status()
		if (status == stream_peer.Status.STATUS_ERROR) or (status == stream_peer.Status.STATUS_NONE):
			force_disconnect("Unkown disconnected by player.")
		
		while (packet_peer.get_available_packet_count() > 0):
			var data: Variant = packet_peer.get_var()
			if data is Array:
				if data.size() < 1: return
				var packet_type: String = data[0]
				data.pop_at(0)
				var packet_data: Array = data
				packet_received.emit(packet_type, packet_data)
