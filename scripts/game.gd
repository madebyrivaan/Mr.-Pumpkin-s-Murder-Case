extends Node2D
class_name DialogueHandler

static var Instance: DialogueHandler = null
signal next_line_prompted
var reading_dialogue: bool
var current_text : String

var counter : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Instance == null:
		Instance = self
	else:
		queue_free()
		return
	reading_dialogue = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not reading_dialogue: return
	if event.is_action_pressed("interact"):
		next_line_prompted.emit()
	

func load_dialogue(dialogue: Array[String]) -> void:
	reading_dialogue = true
	for text in dialogue:
		if text:
			current_text = text
		counter += 1
		await next_line_prompted
	reading_dialogue = false
	
		
