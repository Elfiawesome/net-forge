class_name ConnectionNetworkLayer extends NetworkLayer

var client: NetworkLib.NetworkClient

func connect_to_server(_user_data: Dictionary) -> void:
	client = NetworkLib.NetworkClient.new(address, port)
	client.connection_lost.connect(
		func(close_connection_msg: NetworkLib.CloseConnectionMsg) -> void:
			data_received.emit("connection_lost", close_connection_msg.serialize())
	)
	client.data_received.connect(
		func(raw_data: Variant) -> void:
			if raw_data is Dictionary:
				var data := raw_data as Dictionary
				var _time: int = data.get("time", -1)
				var packet: Dictionary = data.get("packet", {})
				var packet_name: String = packet.get("packet_name", "")
				var packet_data: Dictionary = packet.get("packet_data", {})
				
				data_received.emit(packet_name, packet_data)
	)
	add_child(client)
	client.connect_to_server(_user_data)

func send_data(packet_name: String, packet_data: Dictionary) -> void:
	client.send_data({
		"time": Time.get_ticks_usec(),
		"packet": {
			"packet_name": packet_name,
			"packet_data": packet_data,
		}
	})
