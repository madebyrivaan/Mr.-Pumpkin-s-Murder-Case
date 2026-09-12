extends Control

@onready var clue_counter_lbl: Label = $TopBar/HBox/ClueCounter
@onready var notebook_btn: Button = $TopBar/HBox/NotebookButton
@onready var interrogate_btn: Button = $TopBar/HBox/InterrogateButton

@onready var popup_panel: Panel = $ObservationPopup
@onready var popup_title: Label = $ObservationPopup/VBox/Title
@onready var popup_desc: Label = $ObservationPopup/VBox/Desc
@onready var popup_icon: TextureRect = $ObservationPopup/Icon
@onready var popup_close_btn: Button = $ObservationPopup/CloseButton
@onready var status_lbl: Label = $StatusBanner

var clues_data := {
	"pumpkin_body": {
		"title": "Mr. Pumpkin's Body",
		"icon": "res://Assets/Art asset/Characters/pumpkin_die.png",
		"text": "Inspector Garlic: 'Mr. Pumpkin lies dead on the carpet. Stricken down, yet... there are zero signs of a physical struggle. How could an attacker overpower him so cleanly without a fight?'"
	},
	"shovel": {
		"title": "Garden Shovel (Murder Weapon)",
		"icon": "res://sprites/evidence/Shovel.png",
		"text": "Inspector Garlic: 'A heavy iron garden shovel. The handle has fingerprints... but why was it driven straight down without any resistance? A frail suspect could never swing this, but someone strong could.'"
	},
	"champagne_bottle": {
		"title": "Champagne Bottle",
		"icon": "res://sprites/evidence/Champagne.png",
		"text": "Inspector Garlic: 'A vintage bottle of estate champagne... half empty. Standard alcohol content, completely untampered.'"
	},
	"champagne_glass": {
		"title": "Champagne Glass",
		"icon": "res://sprites/evidence/Glass.png",
		"text": "Inspector Garlic: 'Wait! The lingering aroma in this glass differs distinctly from the bottle! A sharp, suffocating acidity... concentrated lemon juice! A lethal shock to a pumpkin's hollow core!'"
	},
	"cigar_ash": {
		"title": "Scorched Cigar Ash",
		"icon": "res://sprites/evidence/Cigar ash.png",
		"text": "Inspector Garlic: 'A scorched burn mark on the antique desk left by fresh cigar ash. Mr. Pumpkin hated smoking. Someone sat here puffing angrily during a confrontation.'"
	},
	"diamond_ring": {
		"title": "Dropped Diamond Ring",
		"icon": "res://sprites/evidence/Glass.png",
		"text": "Inspector Garlic: 'An exquisite diamond ring dropped beside the chair. Flawless cut... clearly belonging to a high-society lady who lost her composure.'"
	},
	"document_page": {
		"title": "Torn Document Page",
		"icon": "res://sprites/evidence/Document page.png",
		"text": "Inspector Garlic: 'A torn page from an extortion contract. The edges smell of machine oil and sap from Pumpkin's desk drawer. Someone rifled through here in a hurry.'"
	}
}

func _ready() -> void:
	GameManager.play_bgm("investigation")
	popup_panel.hide()
	status_lbl.hide()
	
	notebook_btn.pressed.connect(_on_notebook_pressed)
	interrogate_btn.pressed.connect(_on_interrogate_pressed)
	popup_close_btn.pressed.connect(func(): popup_panel.hide())
	
	# Connect all clue hotspots
	for clue_id in clues_data.keys():
		var node = get_node_or_null("Clues/" + clue_id)
		if node and node is BaseButton:
			node.pressed.connect(func(): _on_clue_clicked(clue_id))
	
	_update_ui()

func _update_ui() -> void:
	var count: int = GameManager.get_evidence_count()
	var total: int = clues_data.size()
	clue_counter_lbl.text = "Clues Found: %d / %d" % [count, total]
	
	if GameManager.all_clues_found():
		interrogate_btn.disabled = false
		interrogate_btn.text = "Interrogate Suspects ->"
	else:
		interrogate_btn.disabled = true
		interrogate_btn.text = "Find More Clues"

func _on_clue_clicked(clue_id: String) -> void:
	var data = clues_data[clue_id]
	var is_new: bool = GameManager.collect_evidence(clue_id)
	
	popup_title.text = data["title"]
	popup_desc.text = data["text"]
	popup_icon.texture = load(data["icon"])
	popup_panel.show()
	
	if is_new:
		_show_banner("Clue recorded in Detective Notebook!")
	
	_update_ui()
	
	if GameManager.all_clues_found() and is_new:
		_show_banner("All key evidence discovered! Ready to interrogate suspects.")

func _show_banner(msg: String) -> void:
	status_lbl.text = msg
	status_lbl.show()
	var tween = create_tween()
	status_lbl.modulate.a = 1.0
	tween.tween_interval(2.5)
	tween.tween_property(status_lbl, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): status_lbl.hide())

func _on_notebook_pressed() -> void:
	Notebook.toggle()

func _on_interrogate_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/interrogation.tscn")
