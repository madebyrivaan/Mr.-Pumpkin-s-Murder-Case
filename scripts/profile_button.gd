extends TextureButton

@export var profile : String = ""
var profile_matcher : Dictionary = {
	"Test" : ["res://sprites/dummy.png"],
	"Test 2" : ["res://sprites/dummy.png"],
	"Mr. Pumpkin" : ["res://sprites/evidence/Champagne.png", "- Victim of the murder"],
	"Lady Lemon" : ["res://sprites/evidence/Glass.png", ""],
	"Mr. Chili" : ["res://sprites/evidence/Shovel.png", ""],
	"Mr. Onion" : ["res://sprites/evidence/Cigar ash.png", ""]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_profile(profile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	

func match_profile(profile_name : String) -> void:
	if profile_name not in profile_matcher.keys() : return
	texture_normal = load(profile_matcher[profile_name][0])


func _on_pressed() -> void:
	Notebook.profile_name.text = profile
	if profile_matcher[profile][1]:
		Notebook.profile_desc.text = profile_matcher[profile][1]
	else:
		Notebook.profile_desc.text  = "- ???"
	#if Notebook.item_desc.text != Notebook.previous_desc:
		#Notebook.item_desc.text = Notebook.previous_desc
		#Notebook.item_desc.visible_ratio = 0
		#var tween = create_tween()
		#tween.set_trans(Tween.TRANS_LINEAR)
		#tween.tween_property(Notebook.item_desc, "visible_ratio", 1.0, 1.0)
		#await tween.finished
		#tween.kill()
