extends Control

@onready var hub_panel: Panel = $HubPanel
@onready var dialogue_panel: Panel = $DialoguePanel

# Hub buttons
@onready var lemon_btn: Button = $HubPanel/SuspectsGrid/LemonCard/SelectButton
@onready var chili_btn: Button = $HubPanel/SuspectsGrid/ChiliCard/SelectButton
@onready var onion_btn: Button = $HubPanel/SuspectsGrid/OnionCard/SelectButton
@onready var lemon_status: Label = $HubPanel/SuspectsGrid/LemonCard/Status
@onready var chili_status: Label = $HubPanel/SuspectsGrid/ChiliCard/Status
@onready var onion_status: Label = $HubPanel/SuspectsGrid/OnionCard/Status
@onready var suspects_grid: HBoxContainer = $HubPanel/SuspectsGrid

@onready var notebook_btn_hub: Button = $HubPanel/TopBar/NotebookButton
@onready var notebook_btn_diag: Button = $DialoguePanel/NotebookButton
@onready var accuse_btn: Button = $HubPanel/AccuseButton
@onready var garlic_summary_lbl: Label = $HubPanel/GarlicSummary

# Dialogue UI
@onready var diag_portrait: TextureRect = $DialoguePanel/SuspectPortrait
@onready var diag_speaker: Label = $DialoguePanel/SpeakerLabel
@onready var diag_text: Label = $DialoguePanel/TextLabel
@onready var next_btn: Button = $DialoguePanel/NextButton
@onready var choices_box: VBoxContainer = $DialoguePanel/ChoicesBox
@onready var choice_1_btn: Button = $DialoguePanel/ChoicesBox/Choice1
@onready var choice_2_btn: Button = $DialoguePanel/ChoicesBox/Choice2
@onready var back_to_hub_btn: Button = $DialoguePanel/BackToHubButton

var current_suspect := ""
var dialogue_queue: Array[Dictionary] = []
var queue_index := 0

func _ready() -> void:
	GameManager.play_bgm("climax")
	notebook_btn_hub.pressed.connect(func(): Notebook.toggle())
	notebook_btn_diag.pressed.connect(func(): Notebook.toggle())
	back_to_hub_btn.pressed.connect(_return_to_hub)
	accuse_btn.pressed.connect(_go_to_accusation)
	
	lemon_btn.pressed.connect(func(): _start_interrogation("Lady Lemon"))
	chili_btn.pressed.connect(func(): _start_interrogation("Mr. Chili"))
	onion_btn.pressed.connect(func(): _start_interrogation("Mr. Onion"))
	
	next_btn.pressed.connect(_advance_dialogue)
	
	_return_to_hub()

func _return_to_hub() -> void:
	dialogue_panel.hide()
	hub_panel.show()
	_update_hub()

func _update_hub() -> void:
	lemon_status.text = "Status: " + ("✓ Questioned" if GameManager.interrogated_suspects["Lady Lemon"] else "Awaiting Questioning")
	chili_status.text = "Status: " + ("✓ Questioned" if GameManager.interrogated_suspects["Mr. Chili"] else "Awaiting Questioning")
	onion_status.text = "Status: " + ("✓ Questioned" if GameManager.interrogated_suspects["Mr. Onion"] else "Awaiting Questioning")
	
	if GameManager.all_suspects_interrogated():
		accuse_btn.disabled = false
		accuse_btn.text = "Make Final Accusation ->"
		garlic_summary_lbl.text = "Deduction Ready:\n• Pumpkin had zero struggle wounds.\n• Chili threw the shovel down unswung.\n• Onion found Pumpkin already dying of poison before any shovel strike!\n• The champagne glass had concentrated lemon acidity!\nReady to name the murderer!"
		suspects_grid.hide()
		garlic_summary_lbl.position.y = 201.0;
		garlic_summary_lbl.show()
	else:
		accuse_btn.disabled = true
		accuse_btn.text = "Interrogate All Suspects First"
		garlic_summary_lbl.text = "Interrogate each suspect to uncover their alibis and contradictions."
		garlic_summary_lbl.show()

func _start_interrogation(suspect_name: String) -> void:
	current_suspect = suspect_name
	hub_panel.hide()
	dialogue_panel.show()
	
	var icon_path: String = GameManager.suspect_db[suspect_name]["icon"]
	diag_portrait.texture = load(icon_path)
	
	dialogue_queue.clear()
	queue_index = 0
	choices_box.hide()
	next_btn.show()
	
	if suspect_name == "Lady Lemon":
		_build_lemon_dialogue()
	elif suspect_name == "Mr. Chili":
		_build_chili_dialogue()
	elif suspect_name == "Mr. Onion":
		_build_onion_dialogue()
	
	_display_current_node()

# --- LADY LEMON DIALOGUE ---
func _build_lemon_dialogue() -> void:
	dialogue_queue = [
		{
			"speaker": "Lady Lemon",
			"text": "I hope this conversation doesn't take too much time, Inspector. I have no desire to linger at a murder scene any longer than necessary."
		},
		{
			"speaker": "Garlic",
			"text": "As a 25-year friend of the victim, you would notice any anomaly. How do you explain your visit to his study?",
			"choices": [
				"Inquire politely about her meeting with Pumpkin",
				"Confront her directly with the dropped Diamond Ring"
			]
		}
	]

func _on_lemon_choice(choice_idx: int) -> void:
	choices_box.hide()
	next_btn.show()
	if choice_idx == 0:
		dialogue_queue.append({
			"speaker": "Lady Lemon",
			"text": "I merely dropped by to congratulate him on our 25-year partnership. Nothing was out of the ordinary!"
		})
		dialogue_queue.append({
			"speaker": "Garlic",
			"text": "Nothing? Then why did we find your personal diamond ring dropped on the floor near his desk?"
		})
	
	dialogue_queue.append({
		"speaker": "Lady Lemon",
		"text": "*Gasp!* Oh... that ring! Pumpkin was a vile monster! I proposed a stock merger to preserve Green Lemon's legacy, but he insulted me as a 'scrawny leech'!"
	})
	dialogue_queue.append({
		"speaker": "Lady Lemon",
		"text": "Trashing 25 years of friendship! In a blind rage, I threw my ring in his face and stormed out! That is why the ring was there!"
	})
	dialogue_queue.append({
		"speaker": "Garlic",
		"text": "Did you see anyone else approaching the study as you left?"
	})
	dialogue_queue.append({
		"speaker": "Lady Lemon",
		"text": "I saw Chili enter right after me—he looked utterly furious! And Onion was lurking in that dark hallway corner! Furthermore, look at me: I am far too delicate to swing a heavy iron shovel! Chili is the violent brute, not me!"
	})
	
	GameManager.add_suspect_note("Lady Lemon", "Threw diamond ring in Pumpkin's face after he insulted her as a 'scrawny leech'.")
	GameManager.add_suspect_note("Lady Lemon", "Saw Chili enter furious, and Onion lurking outside.")
	GameManager.add_suspect_note("Lady Lemon", "Claims she is physically too frail to swing a heavy shovel.")
	GameManager.mark_interrogated("Lady Lemon")
	
	_advance_dialogue()

# --- MR. CHILI DIALOGUE ---
func _build_chili_dialogue() -> void:
	dialogue_queue = [
		{
			"speaker": "Mr. Chili",
			"text": "Make it quick, Detective. I don't have all day to stand around smelling a murder scene."
		},
		{
			"speaker": "Garlic",
			"text": "Mr. Chili, your bank is facing an urgent audit. What was your business with Mr. Pumpkin tonight?",
			"choices": [
				"Press him on the uncollateralised loan documents",
				"Confront him with the cigar ash and shovel fingerprints"
			]
		}
	]

func _on_chili_choice(choice_idx: int) -> void:
	choices_box.hide()
	next_btn.show()
	if choice_idx == 0:
		dialogue_queue.append({
			"speaker": "Mr. Chili",
			"text": "That was standard banking procedure for high-priority partners! Stop trying to twist routine paperwork into a motive!"
		})
		dialogue_queue.append({
			"speaker": "Garlic",
			"text": "Mr. Pumpkin defaulted on that loan, and his desk had your fresh cigar ash—plus a shovel bearing your prints!"
		})
	else:
		dialogue_queue.append({
			"speaker": "Mr. Chili",
			"text": "So what if I smoked a cigar?! That doesn't prove I murdered anyone!"
		})
	
	dialogue_queue.append({
		"speaker": "Mr. Chili",
		"text": "FINE! If you must know, that ungrateful fraud backed me into a corner over his debts! In a fit of blind rage, I grabbed that damned garden shovel from the corner to threaten him!"
	})
	dialogue_queue.append({
		"speaker": "Garlic",
		"text": "You grabbed the shovel to threaten him?!"
	})
	dialogue_queue.append({
		"speaker": "Mr. Chili",
		"text": "YES! But I NEVER struck him! I threw the shovel down on the floor and stormed out! As I left, I saw Lemon storming off and Onion creeping around like a parasite! I didn't kill him!"
	})
	
	GameManager.add_suspect_note("Mr. Chili", "Facing ruin from Pumpkin's loan default.")
	GameManager.add_suspect_note("Mr. Chili", "Admits grabbing the shovel to threaten Pumpkin, but claims he threw it on the floor without striking.")
	GameManager.add_suspect_note("Mr. Chili", "Saw Lemon storm off and Onion creeping around the hallway.")
	GameManager.mark_interrogated("Mr. Chili")
	
	_advance_dialogue()

# --- MR. ONION DIALOGUE ---
func _build_onion_dialogue() -> void:
	dialogue_queue = [
		{
			"speaker": "Mr. Onion",
			"text": "Make it quick, Detective. The air out here is far more pleasant than your interrogation routines."
		},
		{
			"speaker": "Garlic",
			"text": "You claim you never set foot in Pumpkin's office, yet we found a torn document page.",
			"choices": [
				"Present the torn smuggling contract page",
				"Point out the machine oil and plant sap on his suit sleeve"
			]
		}
	]

func _on_onion_choice(choice_idx: int) -> void:
	choices_box.hide()
	next_btn.show()
	if choice_idx == 1:
		dialogue_queue.append({
			"speaker": "Mr. Onion",
			"text": "Hmph... a sharp nose you have, Garlic. Very well. Peeling back the first layer..."
		})
	dialogue_queue.append({
		"speaker": "Mr. Onion",
		"text": "I slipped into the office after Chili stormed out, purely to retrieve my extortion contract from Pumpkin's desk."
	})
	dialogue_queue.append({
		"speaker": "Garlic",
		"text": "You were the last person inside before the body was found. What did you see?"
	})
	dialogue_queue.append({
		"speaker": "Mr. Onion",
		"text": "Listen very carefully, Detective: When I entered, Pumpkin was ALREADY collapsed face-down on the desk, breathing faintly! He had NO shovel in him, and there was NO blood!"
	})
	dialogue_queue.append({
		"speaker": "Garlic",
		"text": "He was already collapsed and dying before any shovel struck him?!"
	})
	dialogue_queue.append({
		"speaker": "Mr. Onion",
		"text": "Precisely. The shovel Chili threw down was resting on the carpet. I grabbed my contract and slipped out into the shadows. Whoever used that shovel did so AFTER he was already poisoned!"
	})
	
	GameManager.add_suspect_note("Mr. Onion", "Entered after Chili to steal back his extortion contract.")
	GameManager.add_suspect_note("Mr. Onion", "Crucial fact: Saw Pumpkin already unconscious and dying on the desk before any shovel struck!")
	GameManager.add_suspect_note("Mr. Onion", "Confirms the shovel strike was staged after Pumpkin was already poisoned.")
	GameManager.mark_interrogated("Mr. Onion")
	
	_advance_dialogue()

func _display_current_node() -> void:
	if queue_index >= dialogue_queue.size():
		_return_to_hub()
		return
	
	var node = dialogue_queue[queue_index]
	diag_speaker.text = node["speaker"]
	diag_text.text = node["text"]
	
	if node.has("choices"):
		next_btn.hide()
		choices_box.show()
		var ch: Array = node["choices"]
		choice_1_btn.text = "1. " + ch[0]
		choice_2_btn.text = "2. " + ch[1]
		for c in choice_1_btn.pressed.get_connections(): choice_1_btn.pressed.disconnect(c.callable)
		for c in choice_2_btn.pressed.get_connections(): choice_2_btn.pressed.disconnect(c.callable)
		
		if current_suspect == "Lady Lemon":
			choice_1_btn.pressed.connect(func(): _on_lemon_choice(0))
			choice_2_btn.pressed.connect(func(): _on_lemon_choice(1))
		elif current_suspect == "Mr. Chili":
			choice_1_btn.pressed.connect(func(): _on_chili_choice(0))
			choice_2_btn.pressed.connect(func(): _on_chili_choice(1))
		elif current_suspect == "Mr. Onion":
			choice_1_btn.pressed.connect(func(): _on_onion_choice(0))
			choice_2_btn.pressed.connect(func(): _on_onion_choice(1))
	else:
		choices_box.hide()
		next_btn.show()
		if queue_index == dialogue_queue.size() - 1:
			next_btn.text = "Finish Questioning ->"
		else:
			next_btn.text = "Next ->"

func _advance_dialogue() -> void:
	queue_index += 1
	_display_current_node()

func _go_to_accusation() -> void:
	get_tree().change_scene_to_file("res://scenes/final_accusation.tscn")
