extends ServerSpaceManager.ServerSpace
# Here we can store all entities in the area etc etc

var map_area_name: String = "null"
var tint_color: Color # Just to show that we can bring save files onto the server

func add_client_to_space(client_id: String) -> void:
	super.add_client_to_space(client_id)
	send_data(client_id, "spawn_map")

func load_from_json(map_json: Dictionary) -> void:
	name = map_json.get("name", "null")
	name = "MAP_" + name
	tint_color = Color(map_json.get("tint_color", "#ffffff") as String)
	
	print("Loaded '%s' map from JSON!" % name)

func save_into_json() -> Dictionary:
	return {
		
	}
