extends PacketHandlerClient
# Smol request by server asking us (client) our data

func run(client: Client, _data: Array) -> void:
	client.network_client_manager.connection.send_data("connection_request", [client.network_client_manager.connection._request_data])
