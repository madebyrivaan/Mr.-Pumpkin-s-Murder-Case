extends CanvasLayer
@onready var evidence = $Notebook/Evidence/EvidenceGrid
@onready var item_name = $Notebook/Evidence/ItemName
@onready var item_desc = $Notebook/Evidence/ItemDesc
var previous_desc = ""
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
	
	#if $Notebook/Evidence/ItemDesc.text != previous_desc:
		#$Notebook/Evidence/ItemDesc.text = previous_desc
		#$Notebook/Evidence/ItemDesc.visible_ratio = 0
		#var tween = create_tween()
		#tween.set_trans(Tween.TRANS_LINEAR)
		#tween.tween_property(item_desc, "visible_ratio", 1.0, 1.0)
		#await tween.finished
		#tween.kill()

func add_evidence(evidence_name : String) -> void:
	var new_evidence = evidence.get_child(evidence_counter)
	new_evidence.match_evidence(evidence_name)
	
	
