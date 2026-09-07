extends Area2D

# IMPORTANT! Always leave array element 0 of flavor_text empty.
@export var flavor_text: Array[String]
# Called when the node enters the scene tree for the first time.
	
func _ready() -> void:
	set_process_input(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if DialogueHandler.Instance.reading_dialogue: return
	if event.is_action_pressed("interact"):
		DialogueHandler.Instance.load_dialogue(flavor_text)
			
func _mouse_enter() -> void:
	if DialogueHandler.Instance.reading_dialogue: return
	set_process_input(true)
func _mouse_exit() -> void:
	if DialogueHandler.Instance.reading_dialogue: return
	set_process_input(false)
