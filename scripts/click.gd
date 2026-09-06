extends Area2D

@export var flavor_text: Array[String]
var hovered: bool
# Called when the node enters the scene tree for the first time.
	
func _ready() -> void:
	hovered = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not hovered: return
	if event.is_action_pressed("interact"):
		print("A click!")
			
func _mouse_enter() -> void:
	hovered = true
func _mouse_exit() -> void:
	hovered = false
