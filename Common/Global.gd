extends Node

var instance_num := 0
var _instance_socket: TCPServer

func _ready() -> void:
	_get_instance_number()

func _get_instance_number() -> void:
	if OS.is_debug_build():
		_instance_socket = TCPServer.new()
		for n in range(0, 10):
			if _instance_socket.listen(5000 + n) == OK:
				instance_num = n
				break
		assert(instance_num >= 0, "Unable to determine instance number. Seems like all TCP ports are in use")
		var screen_size := DisplayServer.screen_get_usable_rect().size
		
		
		get_window().title = str(instance_num)
		get_window().size = screen_size/2
		match instance_num:
			0: get_window().position = Vector2(0,40) + Vector2(0,0)
			1: get_window().position = Vector2(0,40) + Vector2(screen_size.x/2,0)
			2: get_window().position = Vector2(0,40) + Vector2(0,screen_size.y/2)
			3: get_window().position = Vector2(0,40) + Vector2(screen_size.x/2,screen_size.y/2)
