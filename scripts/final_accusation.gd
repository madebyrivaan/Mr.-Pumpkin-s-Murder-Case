extends Control

@onready var prompt_panel: Panel = $PromptPanel
@onready var result_panel: Panel = $ResultPanel

# Accusation buttons
@onready var accuse_lemon_btn: Button = $PromptPanel/SuspectsGrid/LemonCard/AccuseButton
@onready var accuse_chili_btn: Button = $PromptPanel/SuspectsGrid/ChiliCard/AccuseButton
@onready var accuse_onion_btn: Button = $PromptPanel/SuspectsGrid/OnionCard/AccuseButton
@onready var review_notes_btn: Button = $PromptPanel/ReviewNotesButton

# Result UI
@onready var result_title: Label = $ResultPanel/ResultTitle
@onready var result_portrait: TextureRect = $ResultPanel/SuspectPortrait
@onready var result_text: Label = $ResultPanel/ResultText
@onready var next_step_btn: Button = $ResultPanel/NextStepButton
@onready var restart_btn: Button = $ResultPanel/RestartButton

var lemon_ending_steps: Array[Dictionary] = []
var lemon_step_idx := 0

func _ready() -> void:
	result_panel.hide()
	prompt_panel.show()
	
	accuse_lemon_btn.pressed.connect(_on_accuse_lemon)
	accuse_chili_btn.pressed.connect(_on_accuse_chili)
	accuse_onion_btn.pressed.connect(_on_accuse_onion)
	review_notes_btn.pressed.connect(func(): Notebook.toggle())
	
	restart_btn.pressed.connect(_on_restart)
	next_step_btn.pressed.connect(_on_lemon_next_step)

func _on_accuse_chili() -> void:
	prompt_panel.hide()
	result_panel.show()
	next_step_btn.hide()
	restart_btn.show()
	
	result_title.text = "BAD ENDING: THE RED HERRING"
	result_title.modulate = Color(1.0, 0.4, 0.4)
	result_portrait.texture = load("res://Assets/Art asset/Characters/chili.png")
	result_text.text = "Mr. Chili explodes in red-faced fury:\n'YOU INCOMPETENT FOOL! I told you I never struck him! The shovel had no signs of a struggle!'\n\nThe police arrest Chili on circumstantial fingerprint evidence. But that very night, Lady Lemon quietly boards the midnight train with Pumpkin's fortune, raising a toast in her feather boa.\n\nAn innocent man took the fall. The true killer walked free.\n\nCASE UNSOLVED."

func _on_accuse_onion() -> void:
	prompt_panel.hide()
	result_panel.show()
	next_step_btn.hide()
	restart_btn.show()
	
	result_title.text = "BAD ENDING: THE BROKER ESCAPES"
	result_title.modulate = Color(1.0, 0.4, 0.4)
	result_portrait.texture = load("res://Assets/Art asset/Characters/onion.png")
	result_text.text = "Mr. Onion smirks coldly:\n'Arresting me for murder based on a stolen paper? My attorneys will shred your badge by morning, Detective.'\n\nAutopsy toxicology reports soon prove Mr. Pumpkin died of severe internal chemical poisoning prior to any shovel strike. By dawn, Lady Lemon has fled across the border with the estate shares.\n\nJustice was cheated.\n\nCASE UNSOLVED."

func _on_accuse_lemon() -> void:
	GameManager.play_bgm("climax")
	prompt_panel.hide()
	result_panel.show()
	restart_btn.hide()
	next_step_btn.show()
	
	lemon_ending_steps = [
		{
			"title": "CONFRONTATION: LADY LEMON",
			"color": Color(1.0, 0.95, 0.86),
			"portrait": "res://Assets/Art asset/Characters/lemon_dialog.png",
			"text": "Lady Lemon laughs nervously:\n'Me?! What utter nonsense! A delicate high-society lady like me wielding a heavy iron shovel against a grown man? You have lost your mind, Inspector!'"
		},
		{
			"title": "GARLIC'S DEDUCTION",
			"color": Color(1.0, 0.95, 0.86),
			"portrait": "res://Assets/Art asset/Characters/detective.png",
			"text": "Inspector Garlic:\n'You never swung that shovel, Lady Lemon!\nMr. Pumpkin had ZERO signs of physical struggle because he was already incapacitated before the shovel struck!\n\nWhen he rejected your share merger and insulted you as a \"scrawny leech\", you spiked his champagne with concentrated lemon juice!\n\nThe extreme biological acidity triggered fatal toxic shock in his hollow pumpkin constitution!\n\nAnd when you returned to the office, you saw Chili's discarded shovel. You stepped on the blade with your heel, driving it deep to frame Chili!'"
		},
		{
			"title": "CONFESSION BREAKDOWN",
			"color": Color(1.0, 0.8, 0.2),
			"portrait": "res://Assets/Art asset/Characters/lemon_profile.png",
			"text": "Lady Lemon's veneer shatters into hysterical sobs and rage:\n'A SCRAWNY LEECH?! After 25 years of devotion?!\nHe deserved to rot! His hollow, arrogant core couldn't even stomach a few drops of real lemon!\nHe thought his wealth made him a king... and I crushed him!'"
		},
		{
			"title": "TRUE ENDING: CASE SOLVED!",
			"color": Color(0.4, 1.0, 0.5),
			"portrait": "res://Assets/Art asset/Characters/detective.png",
			"text": "Lady Lemon is taken into police custody, fully confessing to premeditated poisoning and staging the crime scene.\n\nChili is exonerated of murder, and Onion's illegal extortion ring is dismantled.\n\nOutside Haven Manor, the storm clears as dawn breaks.\nTwenty-five years of friendship, brought to ruin by greed and wounded vanity.\n\nCASE CLOSED."
		}
	]
	
	lemon_step_idx = 0
	_show_lemon_step(0)

func _show_lemon_step(idx: int) -> void:
	lemon_step_idx = idx
	var data = lemon_ending_steps[idx]
	result_title.text = data["title"]
	result_title.modulate = data["color"]
	result_portrait.texture = load(data["portrait"])
	result_text.text = data["text"]
	
	if idx >= lemon_ending_steps.size() - 1:
		next_step_btn.hide()
		restart_btn.text = "Continue ->"
		restart_btn.show()
	else:
		next_step_btn.text = "Continue ->"
		next_step_btn.show()

func _on_lemon_next_step() -> void:
	if lemon_step_idx < lemon_ending_steps.size() - 1:
		_show_lemon_step(lemon_step_idx + 1)

func _on_retry() -> void:
	result_panel.hide()
	prompt_panel.show()

func _on_restart() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
