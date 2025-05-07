class_name ServerSpace extends Node

var id: String # Unique identifier
var space_type: String
var connected_clients: Array[String] = []
var server_bus: Server.ServerBus

func client_joined(client_id: String) -> void:
	if !(client_id in connected_clients):
		connected_clients.push_back(client_id)

func client_left(client_id: String) -> void:
	if (client_id in connected_clients):
		connected_clients.erase(client_id)
