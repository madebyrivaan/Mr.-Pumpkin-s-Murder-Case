@icon("res://sprites/icons/door.png")
class_name Clickable

extends TextureButton
# IMPORTANT! Always leave array element 0 of flavor_text empty.
@export var flavor_text: Array[String]

# Called when the node enters the scene tree for the first time.
	
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Keeping this in case the buttons stop working
#func _input(event: InputEvent) -> void:
	#if DialogueHandler.Instance.reading_dialogue: return
	#if event.is_action_pressed("interact"):
		#DialogueHandler.Instance.load_dialogue(flavor_text)
			#
#func _mouse_enter() -> void:
	#if DialogueHandler.Instance.reading_dialogue: return
	#set_process_input(true)
	#
#func _mouse_exit() -> void:
	#if DialogueHandler.Instance.reading_dialogue: return
	#set_process_input(false)


func _on_pressed() -> void:
	if DialogueHandler.reading_dialogue: return
	elif DialogueHandler.counter == len(flavor_text):
		DialogueHandler.counter = 0
		DialogueHandler.current_text = flavor_text[0]
		return
	DialogueHandler.load_dialogue(flavor_text)
	DialogueHandler.current_text = flavor_text[0]
	Notebook.add_evidence(name)
	await DialogueHandler.done
	queue_free()
