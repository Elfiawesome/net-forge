extends Node

var instance_num := 0
var username: String
var pid: int

func _ready() -> void:
	_get_instance_number()

func _get_instance_number() -> void:
	if OS.is_debug_build():
		instance_num = int(OS.get_cmdline_args()[1])
		username = "Elfiawesome" + str(instance_num)
		var screen_size := Vector2(DisplayServer.screen_get_usable_rect().size)
		
		
		var TITLEBAR_Y: int = 40
		var starting_point: Vector2
		if instance_num == 0: starting_point = Vector2(0, 0)
		elif instance_num == 1: starting_point = Vector2(screen_size.x/2, 0)
		elif instance_num == 2: starting_point = Vector2(0, screen_size.y/2)
		elif instance_num == 3: starting_point = screen_size/2
		
		starting_point.y += TITLEBAR_Y
		get_window().size = screen_size/2
		get_window().size.y -= TITLEBAR_Y
		get_window().position = starting_point
