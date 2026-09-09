extends CanvasLayer

@onready var evidence = $Notebook/Evidence/EvidenceGrid
var found_evidence_list : Array = []
var evidence_counter : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = !get_tree().paused
		visible = !visible
		

func add_evidence(evidence_name : String) -> void:
	var new_evidence = evidence.get_child(evidence_counter)
	new_evidence.match_evidence(evidence_name)
	
	
