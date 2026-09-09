extends TextureButton

var found_evidence = []
var evidence_matcher : Dictionary = {
	"Test" : ["res://sprites/dummy.png"],
	"Test 2" : ["res://sprites/dummy.png"],
	"Bottle" : [],
	"Glass" : [],
	"Shovel" : [],
	"Cigar ash" : [],
	"Diamond ring" : [],
	"Document page" : []
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	

func match_evidence(evidence_name : String) -> void:
	if evidence_name not in evidence_matcher.keys() : return
	elif evidence_name in found_evidence : return
	texture_normal = load(evidence_matcher[evidence_name][0])
	show()
	found_evidence.append(evidence_name)
	Notebook.evidence_counter += 1
	print(evidence_name)
	print(found_evidence)
