class_name Server extends Node

signal data_send(player_id: String, packet_name: String, packet_data: Dictionary)
signal kick_player(player_id: String, reason: String, authorizer: String)

var global_player_list: Dictionary[String, PlayerData]

@onready var world_service: RemoteWorldService = $RemoteWorldService

func _ready() -> void:
	# Register server resource
	CommonRegistryService.register_server_resource()
	
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.timeout.connect(update_entities)

func player_request_connection(player_id: String, _user_data: Dictionary) -> void:
	if player_id in global_player_list:
		printerr("[Server]: Can't add player who is already in the server session")
		return
	
	var player_data := PlayerData.new()
	
	var world := world_service.get_world("crystal_bay")
	if player_id in world.connected_players:
		printerr("[Server]: Can't add player who is already in the world session")
		return
	
	var player_avatar: RemotePlayerAvatar = world.entity_service.create_entity("player_avatar")
	player_avatar.position = Vector2(randi_range(100,300),randi_range(100,300))
	send_data(player_id, "world_update/load_world_package", {
		"owned_entity_id": player_avatar.entity_id,
		"snapshot": world.get_snapshot(),
	})
	
	player_data.world_id = world.world_type
	player_data.entity_id = player_avatar.entity_id
	
	for _player_id in world.connected_players:
		send_data(_player_id, "world_update/create_entities", {player_avatar.entity_id: player_avatar.serialize()})
	
	world.connected_players.push_back(player_id)
	global_player_list[player_id] = player_data

func player_disconnect(player_id: String) -> void:
	var player_data: PlayerData = global_player_list.get(player_id, null) as PlayerData
	if !player_data:
		printerr("[Server]: Can't disconnect a player that doesn't exists")
		return
	if player_data.world_id:
		var world := world_service.get_world(player_data.world_id)
		world.connected_players.erase(player_id)
		world.entity_service.destroy_entity(player_data.entity_id)
		for _player_id in world.connected_players:
			send_data(_player_id, "world_update/destroy_entities", {player_data.entity_id:{}})
	
	global_player_list.erase(player_id)

func send_data(player_id: String, packet_name: String, packet_data: Dictionary) -> void:
	data_send.emit(player_id, packet_name, packet_data)

func run_packet(player_id: String, packet_name: String, packet_data: Dictionary) -> void:
	var packet: ServerBoundPacket = Registries.get_instance(Registries.SERVER_BOUND_PACKET, packet_name)
	if !packet:
		printerr("Server can't get packet %s" % packet_name)
		return
	packet.run(self, player_id, packet_data)

func update_entities() -> void:
	for world_id in world_service._worlds:
		var world := world_service._worlds[world_id]
		for player_id in world.connected_players:
			var entities := {}
			for entity_id in world.entity_service._entities:
				if entity_id != global_player_list[player_id].entity_id:
					var entity := world.entity_service._entities[entity_id]
					entities[entity_id] = entity.serialize()
			
			send_data(player_id, "world_update/update_player_avatars", {
					"entities": entities
			})

class PlayerData:
	var world_id: String = ""
	var entity_id: String = ""
