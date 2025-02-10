class_name Server extends Node

signal data_send(player_id: String, packet_name: String, packet_data: Dictionary)
signal kick_player(player_id: String, reason: String, authorizer: String)

var global_player_list: Dictionary[String, PlayerData]

@onready var world_service: RemoteWorldService = $RemoteWorldService

func _ready() -> void:
	# Register server resource
	CommonRegistryService.register_server_resource()

func player_request_connection(player_id: String, _user_data: Dictionary) -> void:
	if player_id in global_player_list:
		# Can't add a player who is already in the server session
		return
	
	var player_data := PlayerData.new()
	global_player_list[player_id] = player_data
	
	var world := world_service.get_world("crystal_bay")
	var player_avatar: RemotePlayerAvatar = world.entity_service.create_entity("player_avatar")
	
	send_data(player_id, "world_update/load_world_package", world.get_snapshot())

func send_data(player_id: String, packet_name: String, packet_data: Dictionary) -> void:
	data_send.emit(player_id, packet_name, packet_data)


class PlayerData:
	var dimension_id: String = ""
	var entity_id: String = ""
