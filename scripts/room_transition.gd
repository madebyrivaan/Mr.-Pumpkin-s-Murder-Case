extends Node
var current_room: String
const room_scenes_dir = "res://scenes/rooms/"
# Representation
var linked_rooms: Array[String]


func load_room(room_id: String) -> void:
	if room_id not in linked_rooms: return
	
func get_linked_rooms(room_id: String) -> Array[String]:
	# If you'd like to get the stuff in the room_transition file itself with JSON instead that's okay,
	# I didn't get much done with my attempt at it
	# Essentially the idea was to parse the file for the current room string as key, with the rooms either
	# in a list or a single space separated string.
	# Alternatively if there won't be too many rooms we could do with a single BitMap acting as a matrix of neighboring
	# rooms, with 1 (true) in row i and column j as room i and j connected, and 0 (false) as no link, then go along
	# the row and get all the true ones to then have those as the linked rooms array.
	# Just wanted to write down here what ideas I had in mind. Do what you think would be best here.
	pass
	
	
	
	
