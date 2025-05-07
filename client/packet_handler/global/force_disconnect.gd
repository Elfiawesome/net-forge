extends PacketHandlerClient
# Disconnected from the server
# data: [{"reason": String}]

func run(client: Client, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_DICTIONARY]): return
	var disconnect_data: Dictionary = data[0]
	# TODO: Make it so that when we receive a disconnect packet, we should already 
	# be disconnected and not accepting any other packets beyond this points
	# TODO: Make it so that we can do a get_status() from client network manager to see if we need to send this message 	
	client.top_overlay.set_overlay_message("Disconnected from server", disconnect_data.get("reason", "Unknown reason"))
	client.top_overlay.display()
	
	client.network_client_manager.connection.leave_server()
