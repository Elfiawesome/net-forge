class_name GameClient extends Node2D

var stream: StreamPeerTCP
var peer: PacketPeerStream

func _ready() -> void:
	if Global.instance_num == 0:
		create_server()
	
	stream = StreamPeerTCP.new()
	stream.connect_to_host("127.0.0.1", 3115)
	peer = PacketPeerStream.new()
	peer.stream_peer = stream

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			stream.poll()
			peer.put_var({"username":"Elfi"})

func create_server() -> void:
	var server := preload("res://Server/GameServer.tscn").instantiate()
	add_child(server)
