class_name GameSession extends CanvasLayer

var network_connection: NetworkConnection

@onready var disconnect_panel: Panel = $DisconnectPanel
@onready var disconnect_label: Label = $DisconnectPanel/Label


func _ready() -> void:
	if Global.instance_num == 0:
		var server := preload("res://server/server.tscn").instantiate()
		add_child(server)
	
	network_connection = NetworkConnection.new()
	network_connection.packet_received.connect(_on_handle_data)
	add_child(network_connection)
	network_connection.connect_to_server("127.0.0.1", 3115, "Elfiawesome23" + str(Global.instance_num))

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_Q and event.pressed:
			network_connection.leave_server()

func _process(delta: float) -> void:
	$UI/Label.text = "Status: %s" % network_connection.get_status()

func _on_handle_data(type: String, data: Array) -> void:
	print("Client packet: " + type + " -> " +str(data))
	var handler := PacketHandlerClient.get_handler(type)
	if !handler: return
	handler.run(self, data)

class NetworkConnectionBase extends Node:
	func connect_to_server(address_: String, port_: int, username: String) -> void: pass
	func get_status() -> int: return 0
	func leave_server() -> void: pass

class NetworkConnection extends NetworkConnectionBase:
	signal packet_received(type: String, data: Array)
	
	var address: String = "127.0.0.1"
	var port: int = 3115
	
	var stream_peer: StreamPeerTCP
	var packet_peer: PacketPeerStream
	
	func _init() -> void:
		pass
	
	func connect_to_server(address_: String, port_: int, username: String) -> void:
		address = address_
		port = port_
		
		stream_peer = StreamPeerTCP.new()
		packet_peer = PacketPeerStream.new()
		
		stream_peer.connect_to_host(address, port)
		packet_peer.stream_peer = stream_peer
		stream_peer.poll()
		
		packet_peer.put_var(["ConnectionRequest", username])
	
	func get_status() -> int:
		if stream_peer: return stream_peer.get_status()
		return stream_peer.Status.STATUS_NONE
	
	func leave_server() -> void:
		stream_peer.disconnect_from_host()
	
	func _process(_delta: float) -> void:
		stream_peer.poll()
		
		var status := stream_peer.get_status()
		if (status == stream_peer.Status.STATUS_ERROR) or (status == stream_peer.Status.STATUS_NONE):
			pass
		
		while (packet_peer.get_available_packet_count() > 0):
			var data: Variant = packet_peer.get_var()
			if data is Array:
				if data.size() < 1: return
				var packet_type: String = data[0]
				data.pop_at(0)
				var packet_data: Array = data
				packet_received.emit(packet_type, packet_data)
