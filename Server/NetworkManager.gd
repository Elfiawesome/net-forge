class_name NetworkManager extends Node

var tcp_server: TCPServer

func _ready() -> void:
	tcp_server = TCPServer.new()
	tcp_server.listen(3115, "127.0.0.1")


func _process(_delta: float) -> void:
	if tcp_server.is_connection_available():
		print("Connection!")
		var client := Client.new(tcp_server.take_connection())


class Client:
	var stream: StreamPeerTCP
	var peer: PacketPeerStream
	
	func _init(connection: StreamPeerTCP) -> void:
		stream = connection
		peer = PacketPeerStream.new()
		peer.stream_peer = connection
	
	func update() -> void:
		stream.poll()
		var status := stream.get_status()
		if status == stream.Status.STATUS_ERROR or status == stream.Status.STATUS_NONE:
			pass
	
	func push_var(variant: Variant) -> void:
		update()
		peer.put_var(variant)
	
	func get_var() -> Variant:
		if peer.get_available_packet_count() > 0:
			return peer.get_var()
		return
