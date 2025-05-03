extends ServerSpaceManager.ServerSpace
# Here we can store all entities in the area etc etc

var map_area_name: String = "null"

func load_from_json(map_json: Dictionary) -> void:
	print("Loaded map!")

func save_into_json() -> Dictionary:
	return {
		
	}
