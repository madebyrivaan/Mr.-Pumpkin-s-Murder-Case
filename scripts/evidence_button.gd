extends TextureButton

var found_evidence : String = ""
var evidence_matcher : Dictionary = {
	"Test" : ["res://sprites/dummy.png"],
	"Test 2" : ["res://sprites/dummy.png"],
	"Bottle" : ["res://sprites/evidence/Champagne.png", "A vintage bottle... half empty."],
	"Glass" : ["res://sprites/evidence/Glass.png", "Why does the smell of the glass differ from the bottle ?"],
	"Shovel" : ["res://sprites/evidence/Shovel.png", "The murder weapon has fingerprints, belonging to... ?"],
	"Cigar ash" : ["res://sprites/evidence/Cigar ash.png", "A scorched mark left by cigar ash...
	Someone was smoking here, and it wasn't Mr. Pumpkin."],
	"Diamond ring" : [],
	"Document page" : ["res://sprites/evidence/Document page.png", "An important page left on the floor..."]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	

func match_evidence(evidence_name : String) -> void:
	if evidence_name not in evidence_matcher.keys() : return
	elif evidence_name == found_evidence : return
	texture_normal = load(evidence_matcher[evidence_name][0])
	show()
	found_evidence = evidence_name
	Notebook.evidence_counter += 1


func _on_pressed() -> void:
	Notebook.item_name.text = found_evidence
	Notebook.item_desc.text = evidence_matcher[found_evidence][1]
	#if Notebook.item_desc.text != Notebook.previous_desc:
		#Notebook.item_desc.text = Notebook.previous_desc
		#Notebook.item_desc.visible_ratio = 0
		#var tween = create_tween()
		#tween.set_trans(Tween.TRANS_LINEAR)
		#tween.tween_property(Notebook.item_desc, "visible_ratio", 1.0, 1.0)
		#await tween.finished
		#tween.kill()
