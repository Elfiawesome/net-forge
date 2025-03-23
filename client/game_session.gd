extends CanvasLayer

var peer: StreamPeerTCP
var packet: PacketPeerStream

func _ready() -> void:
	if Global.instance_num == 0:
		var server := preload("res://server/server.tscn").instantiate()
		add_child(server)
	
	peer = StreamPeerTCP.new()
	packet = PacketPeerStream.new()
	packet.stream_peer = peer
	peer.connect_to_host("127.0.0.1", 3115)
	peer.poll()
	packet.put_var(["ConnectionRequest", "Elfiawesome23"+str(Global.instance_num)])


func _process(_delta: float) -> void:
	peer.poll()
	$UI/Label.text = Time.get_datetime_string_from_system()
	$UI/Label.text += "\n Status: " + str(peer.get_status())
	
	
	while (packet.get_available_packet_count() > 0):
		var data: Variant = packet.get_var()
		if data is Array:
			if data.size() < 1: return
			var packet_type: String = data[0]
			data.pop_at(0)
			var packet_data: Array = data
			print("Client packet: " + packet_type + " -> " +str(packet_data))
