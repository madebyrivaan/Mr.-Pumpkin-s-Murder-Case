extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not DialogueHandler.Instance.reading_dialogue:
		hide()
		return
	show()
	$"Displayed Text".text = DialogueHandler.Instance.current_text
