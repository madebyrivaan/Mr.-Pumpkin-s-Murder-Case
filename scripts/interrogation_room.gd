extends CanvasGroup

var lady_lemon = FileAccess.open("res://dialogues/lady_lemon.json", FileAccess.READ)
var mr_chili = FileAccess.open("res://dialogues/mr_chili.json", FileAccess.READ)
var mr_onion = FileAccess.open("res://dialogues/mr_onion.json", FileAccess.READ)

var current_dialogue = JSON.parse_string(lady_lemon.get_as_text())

var choice : bool = false
var canInteract : bool = false
var line_counter : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueHandler.load_dialogue([current_dialogue[line_counter]["text"]])
	$ButtonsLayer.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if choice:
		canInteract = false
	elif DialogueHandler.is_processing_input():
		canInteract = true
	else:
		canInteract = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and canInteract:
		next_line()


func next_line() -> void:
	line_counter += 1
	if current_dialogue[line_counter]["type"] == "text":
		choice = false
		$ButtonsLayer.hide()
		DialogueHandler.load_dialogue([current_dialogue[line_counter]["text"]])
	elif current_dialogue[line_counter]["type"] == "choice":
		choice = true
		$ButtonsLayer/Button1.text = current_dialogue[line_counter]["1"]
		$ButtonsLayer/Button2.text = current_dialogue[line_counter]["2"]
		$ButtonsLayer.show()


func _on_button_1_pressed() -> void:
	line_counter = current_dialogue[line_counter]["1r"] - 1
	next_line()


func _on_button_2_pressed() -> void:
	line_counter = current_dialogue[line_counter]["2r"] - 1
	next_line()
