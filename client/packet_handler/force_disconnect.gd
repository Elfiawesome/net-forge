extends PacketHandlerClient
# Disconnected from the server
# data: [{"reason": String}]

func run(client: Client, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_DICTIONARY]): return
	var disconnect_data: Dictionary = data[0]
	client.network_client_manager.connection.leave_server()
