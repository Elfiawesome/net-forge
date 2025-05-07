class_name MainEntryPoint extends Node

const CLIENT_SCENE := preload("res://client/client.tscn")
const SERVER_SCENE := preload("res://server/server.tscn")

var server: Server
var client: Client

func _ready() -> void:
	if Global.instance_num == 0:
		server = SERVER_SCENE.instantiate()
		add_child(server)
	
	client = CLIENT_SCENE.instantiate()
	add_child(client)
	var new_connection: NetworkClientManager.Connection
	if server:
		client.game_config = server.persistance_manager.server_config
		new_connection = NetworkClientManager.IntegratedConnection.new(server.network_manager)
	else:
		new_connection = NetworkClientManager.TCPConnection.new()
		new_connection.set_target("127.0.0.1", 51134)
	client.network_client_manager.connection = new_connection
	client.connect_to_server(Global.username)


func _input(event: InputEvent) -> void:
	if !server: return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			server.shutdown()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if server:
			server.shutdown()
