class_name Server extends Node

func _ready() -> void:
	# Register server resource
	CommonRegistryService.register_server_resource()
	
