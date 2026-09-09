extends Node
static var Instance: RoomTransition
var current_room: String
const room_scenes_dir = "res://scenes/rooms/"
# Representation
var linked_rooms: Array
var room_links_file = FileAccess.open("res://scenes/rooms/room_links.json", FileAccess.READ)
var room_links = JSON.parse_string(room_links_file.get_as_text())

func _ready() -> void:
	if Instance == null:
		Instance = self
	else:
		queue_free()
		return
	current_room = get_tree().get_root().get_child(-1).name
	linked_rooms = get_linked_rooms(current_room)

func load_room(room_id: String) -> void:
	if room_id not in linked_rooms: return
	var next_room_path : String = room_scenes_dir + room_id + ".tscn"
	get_tree().call_deferred("change_scene_to_file", next_room_path)
	current_room = room_id
	linked_rooms = get_linked_rooms(current_room)

func get_linked_rooms(room_id: String) -> Array:
	# If you'd like to get the stuff in the room_transition file itself with JSON instead that's okay,
	# I didn't get much done with my attempt at it
	# Essentially the idea was to parse the file for the current room string as key, with the rooms either
	# in a list or a single space separated string.
	# Alternatively if there won't be too many rooms we could do with a single BitMap acting as a matrix of neighboring
	# rooms, with 1 (true) in row i and column j as room i and j connected, and 0 (false) as no link, then go along
	# the row and get all the true ones to then have those as the linked rooms array.
	# Just wanted to write down here what ideas I had in mind. Do what you think would be best here.
	##Thx, I did it with a .json file
	##For testing purposes, you can switch rooms by pressing space (start in the "main_hall" scene)
	for room in room_links:
		if room == room_id:
			return room_links[room]
	return []
	
	
	
	
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		load_room("bedroom")
