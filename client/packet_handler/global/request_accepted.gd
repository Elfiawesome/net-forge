extends Node
# Runs if everything is good to go. Server has already done connection_request

func run(client: Client, data: Array) -> void:
	if !Schema.is_valid(data, [TYPE_DICTIONARY]): return
	# Depends if we are integrated or not, if we are the game_config should have already been set
	var game_configs_data: Dictionary = data[0]
	
	if !client.game_config:
		client.game_config = ServerConfig.new()
		client.game_config.from_json(game_configs_data)
	
	client.top_overlay.display_not()
