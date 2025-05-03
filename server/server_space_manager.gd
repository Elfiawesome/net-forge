class_name ServerSpaceManager extends Node

signal _sent_data(_client_id: String, _type: String, _client_id_data: Array)

var spaces: Dictionary[String, ServerSpace] = {}

var _client_to_spaces_map: Dictionary[String, Array] = {} # We do this so that we don't need to store unnecessary information on Network.Connection

# Map map_names to their loaded_ids
var _map_name_to_id: Dictionary[String, String] = {}

func add_space(space: ServerSpace) -> void:
	var space_id := UUID.v4()
	spaces[space_id] = space
	space.id = space_id
	space._sent_data.connect(send_data)
	add_child(space)

func remove_space(space_id: String) -> void:
	if space_id in spaces:
		spaces[space_id].queue_free()
		spaces.erase(space_id)

func assign_client_to_space(client_id: String, space_id: String) -> void:
	if _client_to_spaces_map.has(client_id):
		var l := _client_to_spaces_map[client_id]
		if !(client_id in l):
			l.push_back(client_id)
	else:
		_client_to_spaces_map[client_id] = [space_id]

func deassign_client_from_space(client_id: String, space_id: String) -> void:
	if client_id in _client_to_spaces_map:
		var l := _client_to_spaces_map[client_id]
		if space_id in l:
			l.erase(space_id)

func send_data(client_id: String, type: String, data: Array) -> void:
	_sent_data.emit(client_id, type, data)

class ServerSpace extends Node:
	# Generic server space class
	# Extend from this
	
	signal _sent_data(_client_id: String, _type: String, _client_id_data: Array)
	
	var id: String
	var connected_clients: Array[String] = []
	
	func add_client_to_space(client_id: String) -> void:
		if !(client_id in connected_clients):
			connected_clients.push_back(client_id)
	
	func remove_client_from_space(client_id: String) -> void:
		if (client_id in connected_clients):
			connected_clients.erase(client_id)
	
	func send_data(client_id: String, type: String, data: Array = []) -> void:
		_sent_data.emit(client_id, type, data)
	
	func broadcast_data(type: String, data: Array = []) -> void:
		for client_id: String in connected_clients:
			send_data(client_id, type, data)
	
	func broadcast_data_specific(client_list: Array, type: String, data: Array = [], is_exclude: bool = false) -> void:
		if !is_exclude:
			for client_id: String in client_list:
				send_data(client_id, type, data)
		else:
			for client_id: String in connected_clients:
				if !(client_id in client_list):
					send_data(client_id, type, data)

