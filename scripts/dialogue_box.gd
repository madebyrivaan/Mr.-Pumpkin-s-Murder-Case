extends CanvasLayer

var previous_text : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not DialogueHandler.reading_dialogue:
		hide()
		return
	show()
	$"Displayed Text".text = DialogueHandler.current_text
	#Tweening for smoother dialogue - Work In Progress
	if $"Displayed Text".text != previous_text:
		DialogueHandler.set_process_input(false)
		previous_text = $"Displayed Text".text
		$"Displayed Text".visible_ratio = 0
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property($"Displayed Text", "visible_ratio", 1.0, 1.0)
		await tween.finished
		DialogueHandler.set_process_input(true)
		tween.kill()
