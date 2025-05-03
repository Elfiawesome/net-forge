class_name MainEntryPoint extends Node

const CLIENT_SCENE := preload("res://client/client.tscn")
const SERVER_SCENE := preload("res://server/server.tscn")

func _ready() -> void:
	var client := CLIENT_SCENE.instantiate()
	add_child(client)
	
	if Global.instance_num == 0:
		var server := SERVER_SCENE.instantiate()
		add_child(server)
