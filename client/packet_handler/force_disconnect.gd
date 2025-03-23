extends PacketHandlerClient

func run(game: GameSession, data: Array) -> void:
	var disconnect_data: Dictionary = data[0]
	game.disconnect_panel.visible = true
	game.disconnect_label.text = "Disconnected\n"
	game.disconnect_label.text += disconnect_data.get("reason", "")
	game.network_connection.leave_server()
