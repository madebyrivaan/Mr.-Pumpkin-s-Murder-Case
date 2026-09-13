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

@onready var diag_portrait: TextureRect = $DialoguePanel/PortraitFrame/SuspectPortrait
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
var current_lemon_node_id := ""
var current_chili_node_id := ""
var current_onion_node_id := ""

var lemon_tree: Dictionary = {
	"start": {
		"speaker": "Lady Lemon",
		"text": "I hope this conversation doesn't take too much time, Detective. I have no desire to linger at a murder scene any longer than necessary.",
		"choices": [
			{
				"text": "As a refined lady and a 25 year friend of the victim, you would surely notice even the smallest anomaly. Did you observe anything unusual when you visited Mr. Pumpkin's office?",
				"next": "q1_c1_detective"
			},
			{
				"text": "Did your entry into Mr. Pumpkin's office during this 25 year friendship anniversary party serve any specific purpose?",
				"next": "q1_c2_detective"
			}
		]
	},
	"q1_c1_detective": {
		"speaker": "Detective",
		"text": "As a refined lady and a 25 year friend of the victim, you would surely notice even the smallest anomaly. Did you observe anything unusual when you visited Mr. Pumpkin's office?",
		"next": "q1_c1_reply"
	},
	"q1_c1_reply": {
		"speaker": "Lady Lemon",
		"text": "At least you understand my standing, Detective. I merely dropped by to congratulate Pumpkin on our 25 year milestone of friendship and partnership. Nothing was out of the ordinary",
		"choices": [
			{
				"text": "We discovered this exquisite diamond ring on the floor. Given its sophisticated design, I believe only someone with flawless taste could own such a piece. Does this belong to you, Lady Lemon?",
				"next": "ring_win_detective"
			},
			{
				"text": "This valuable diamond ring was recovered from the crime scene floor. Can you confirm or deny whether this item is your personal property?",
				"next": "ring_deny_detective"
			}
		]
	},
	"q1_c2_detective": {
		"speaker": "Detective",
		"text": "Did your entry into Mr. Pumpkin's office during this 25 year friendship anniversary party serve any specific purpose?",
		"next": "q1_c2_reply"
	},
	"q1_c2_reply": {
		"speaker": "Lady Lemon",
		"text": "Purpose? We have been close friends for 25 years, my dropping by to congratulate him was entirely proper etiquette. There is no need to use such an accusatory tone with me",
		"choices": [
			{
				"text": "We discovered this exquisite diamond ring on the floor. Given its sophisticated design, I believe only someone with flawless taste could own such a piece. Does this belong to you, Lady Lemon?",
				"next": "ring_win_detective"
			},
			{
				"text": "This valuable diamond ring was recovered from the crime scene floor. Can you confirm or deny whether this item is your personal property?",
				"next": "ring_deny_detective"
			}
		]
	},
	"ring_win_detective": {
		"speaker": "Detective",
		"text": "We discovered this exquisite diamond ring on the floor. Given its sophisticated design, I believe only someone with flawless taste could own such a piece. Does this belong to you, Lady Lemon?",
		"next": "ring_win_lemon"
	},
	"ring_win_lemon": {
		"speaker": "Lady Lemon",
		"text": "Oh... yes, that is mine. Pumpkin was a monster! On our 25th anniversary, I proposed a stock merger to preserve my late husband's legacy. But he callously humiliated me as a 'scrawny leech'! Trashing 25 years of friendship! In a fit of rage, I threw the ring at his face and stormed out!",
		"choices": [
			{
				"text": "To be insulted like that by a 25 year friend is truly unjust. As you stormed out in distress, did you happen to notice anyone else attempting to approach the office?",
				"next": "win_detective"
			},
			{
				"text": "A betrayal of 25 years of trust must have been devastating. After such a deep humiliation, did you feel compelled to return and continue talking to him?",
				"next": "lose1_detective"
			}
		]
	},
	"win_detective": {
		"speaker": "Detective",
		"text": "To be insulted like that by a 25 year friend is truly unjust. As you stormed out in distress, did you happen to notice anyone else attempting to approach the office?",
		"next": "win_lemon"
	},
	"win_lemon": {
		"speaker": "Lady Lemon",
		"text": "I noticed Chili enter right after I left, and when he walked out, he looked utterly furious. and Mr. Onion, he just kept lingering endlessly in that dark hallway corner, i dislike him far too much to pay him any mind. That is everything I know!",
		"end": true,
		"notes": [
			"The diamond ring belongs to Lady Lemon",
			"Personal conflict between Lady Lemon and Mr. Pumpkin",
			"Mr. Chili exiting Mr. Pumpkin's office in a fit of rage",
			"Mr. Onion lingering continuously in the hallway outside the victim's office"
		]
	},
	"lose1_detective": {
		"speaker": "Detective",
		"text": "A betrayal of 25 years of trust must have been devastating. After such a deep humiliation, did you feel compelled to return and continue talking to him?",
		"next": "lose1_lemon"
	},
	"lose1_lemon": {
		"speaker": "Lady Lemon",
		"text": "Continue talking to him? Lower myself to beg a tyrant who just dragged my pride through the mud? You clearly underestimate my dignity, Detective.",
		"end": true,
		"notes": [
			"The diamond ring belongs to Lady Lemon",
			"Personal conflict between Lady Lemon and Mr. Pumpkin",
			"No witness data on Mr. Chili & Mr. Onion"
		]
	},
	"ring_deny_detective": {
		"speaker": "Detective",
		"text": "This valuable diamond ring was recovered from the crime scene floor. Can you confirm or deny whether this item is your personal property?",
		"next": "ring_deny_lemon"
	},
	"ring_deny_lemon": {
		"speaker": "Lady Lemon",
		"text": "What are you implying, Inspector? This estate is filled with shiny trinkets. If you are trying to frame me using an unconfirmed item, you are gravely mistaken!",
		"choices": [
			{
				"text": "Setting the ring aside, have you had any personal conflicts with Mr. Pumpkin over the past 25 years?",
				"next": "lose2a_detective"
			},
			{
				"text": "There is no mistake, Lady Lemon. Other witnesses have confirmed that this ring belongs to you. I expect you to be honest and cooperative with us",
				"next": "lose2b_detective"
			}
		]
	},
	"lose2a_detective": {
		"speaker": "Detective",
		"text": "Setting the ring aside, have you had any personal conflicts with Mr. Pumpkin over the past 25 years?",
		"next": "lose2_lemon"
	},
	"lose2b_detective": {
		"speaker": "Detective",
		"text": "There is no mistake, Lady Lemon. Other witnesses have confirmed that this ring belongs to you. I expect you to be honest and cooperative with us",
		"next": "lose2_lemon"
	},
	"lose2_lemon": {
		"speaker": "Lady Lemon",
		"text": "I have had enough of your subtle accusations, Detective. Speak to my lawyer!",
		"end": true,
		"notes": [
			"The personal conflict between Lady Lemon and Mr. Pumpkin?",
			"Why Lady Lemon lied about the diamond ring?"
		]
	}
}

var chili_tree: Dictionary = {
	"start": {
		"speaker": "Mr. Chili",
		"text": "Make it quick, Detective. I don't have all day to stand around smelling a murder scene.",
		"choices": [
			{
				"text": "I only need a few minutes, Mr. Chili. Could you please confirm the reason for your presence in Mr. Pumpkin's office before the incident occurred?",
				"next": "q1_c1_detective"
			},
			{
				"text": "Lady Lemon saw you leave the room in an extreme rage. You had a heated argument with the victim, didn't you?",
				"next": "q1_c2_detective"
			}
		]
	},
	"q1_c1_detective": {
		"speaker": "Detective",
		"text": "I only need a few minutes, Mr. Chili. Could you please confirm the reason for your presence in Mr. Pumpkin's office before the incident occurred?",
		"next": "q1_c1_reply"
	},
	"q1_c1_reply": {
		"speaker": "Mr. Chili",
		"text": "I went in purely to smoke a cigar and discuss business matters. We had a completely normal conversation, and then I left",
		"choices": [
			{
				"text": "If it was strictly business, can you clarify why your personal signature appears on his uncollateralised loan documents?",
				"next": "q2_loan_detective"
			},
			{
				"text": "A 'normal conversation'? Your bank is facing an upcoming audit, while Mr. Pumpkin just defaulted on a massive loan you approved against protocol. That wasn't just a casual chat, was it?",
				"next": "q2_audit_detective"
			}
		]
	},
	"q2_loan_detective": {
		"speaker": "Detective",
		"text": "If it was strictly business, can you clarify why your personal signature appears on his uncollateralised loan documents?",
		"next": "q2_loan_reply"
	},
	"q2_loan_reply": {
		"speaker": "Mr. Chili",
		"text": "That is standard banking procedures for high-priority partners, Inspector! It proves we had a solid business relationship, not that I had any reason to harm him. Stop trying to twist routine paperwork!",
		"choices": [
			{
				"text": "Routine paperwork aside, witnesses confirm you and Mr. Pumpkin had a heated argument inside the office. What was that conflict truly about?",
				"next": "q3_conflict_detective"
			},
			{
				"text": "Understood. However, we found a garden shovel with partial fingerprints near the scene. Did you happen to touch or notice any tools in the office during your visit?",
				"next": "q3_shovel_detective"
			}
		]
	},
	"q3_conflict_detective": {
		"speaker": "Detective",
		"text": "Routine paperwork aside, witnesses confirm you and Mr. Pumpkin had a heated argument inside the office. What was that conflict truly about?",
		"next": "lose_end_1_chili"
	},
	"lose_end_1_chili": {
		"speaker": "Mr. Chili",
		"text": "A conflict? That ungrateful fraud backed me into a corner over his debts! But if you want a real killer, stop bugging me and go question Onion! He was lurking in that dark hallway like a rat the entire time! I'm done speaking with you!",
		"end": true,
		"notes": [
			"Has conflict with the victim, but denies it?",
			"Shifts suspicion onto Mr. Onion."
		]
	},
	"q3_shovel_detective": {
		"speaker": "Detective",
		"text": "Understood. However, we found a garden shovel with partial fingerprints near the scene. Did you happen to touch or notice any tools in the office during your visit?",
		"next": "win_end_1_chili"
	},
	"win_end_1_chili": {
		"speaker": "Mr. Chili",
		"text": "Fine! In a fit of rage during our argument, I grabbed that damned garden shovel to threaten him! But I threw it on the floor and walked out! As I left, I saw Lemon storming off and Onion creeping around the hallway like a parasite! Now get out of my way!",
		"end": true,
		"notes": [
			"Admitted conflict with the victim.",
			"Admitted using a shovel to threaten the victim.",
			"Spotted Lady Lemon returning to the victim's office?",
			"Testimony matches Lady Lemon's account regarding Mr. Onion."
		]
	},
	"q1_c2_detective": {
		"speaker": "Detective",
		"text": "Lady Lemon saw you leave the room in an extreme rage. You had a heated argument with the victim, didn't you?",
		"next": "q1_c2_reply"
	},
	"q1_c2_reply": {
		"speaker": "Mr. Chili",
		"text": "What the hell does that Lemon woman know? She spends her whole life holding a grudge against the world! Don't you dare use the testimony of a crazy hag to frame me!",
		"choices": [
			{
				"text": "Please calm down, Mr. Chili. I am not framing anyone based on rumors. I just want to hear your side of the story regarding what actually happened inside the study.",
				"next": "q2_calm_detective"
			},
			{
				"text": "So it wasn't a normal conversation after all, was it? Did Mr. Pumpkin threaten to expose your corruption and bribery evidence to the authorities?",
				"next": "q2_corruption_detective"
			}
		]
	},
	"q2_corruption_detective": {
		"speaker": "Detective",
		"text": "So it wasn't a normal conversation after all, was it? Did Mr. Pumpkin threaten to expose your corruption and bribery evidence to the authorities?",
		"next": "lose_end_2_chili"
	},
	"lose_end_2_chili": {
		"speaker": "Mr. Chili",
		"text": "You dare threaten the Bank President? I will sue you in court for slander! Don't even dream of pinning that charge on me!",
		"end": true,
		"notes": [
			"Has conflict with Lady Lemon?",
			"Has conflict with the victim, but denies it?"
		]
	},
	"q2_audit_detective": {
		"speaker": "Detective",
		"text": "A 'normal conversation'? Your bank is facing an upcoming audit, while Mr. Pumpkin just defaulted on a massive loan you approved against protocol. That wasn't just a casual chat, was it?",
		"next": "merge_auditors_chili"
	},
	"q2_calm_detective": {
		"speaker": "Detective",
		"text": "Please calm down, Mr. Chili. I am not framing anyone based on rumors. I just want to hear your side of the story regarding what actually happened inside the study.",
		"next": "merge_auditors_chili"
	},
	"merge_auditors_chili": {
		"speaker": "Mr. Chili",
		"text": "Enough! Those damned auditors! Pumpkin backed me into a corner! I only picked up that garden shovel to threaten him! The shovel he usually uses to tend plants in the room! But I threw it on the floor and walked out!",
		"choices": [
			{
				"text": "I note your account regarding the shovel, Mr. Chili. I understand you are frustrated and overwhelmed right now, and this is my final question. As you stepped out into the hallway, did you happen to see anyone else around the office?",
				"next": "q3_hallway_detective"
			},
			{
				"text": "You expect me to believe you picked up a shovel in a fit of rage and just threw it down without using it? Tell me the truth, Mr Chili!",
				"next": "q3_disbelieve_detective"
			}
		]
	},
	"q3_hallway_detective": {
		"speaker": "Detective",
		"text": "I note your account regarding the shovel, Mr. Chili. I understand you are frustrated and overwhelmed right now, and this is my final question. As you stepped out into the hallway, did you happen to see anyone else around the office?",
		"next": "win_end_2_chili"
	},
	"win_end_2_chili": {
		"speaker": "Mr. Chili",
		"text": "I left, I saw Lemon storming off and Onion creeping around the hallway like a parasite! We are done here, Detective!",
		"end": true,
		"notes": [
			"Admitted conflict with the victim.",
			"Admitted using a shovel to threaten the victim.",
			"Spotted Lady Lemon returning to the victim's office?",
			"Testimony matches Lady Lemon's account regarding Mr. Onion."
		]
	},
	"q3_disbelieve_detective": {
		"speaker": "Detective",
		"text": "You expect me to believe you picked up a shovel in a fit of rage and just threw it down without using it? Tell me the truth, Mr Chili!",
		"next": "lose_end_3_chili"
	},
	"lose_end_3_chili": {
		"speaker": "Mr. Chili",
		"text": "....... (no reply)",
		"end": true,
		"notes": [
			"Admitted conflict with the victim.",
			"Showed rage when admitting to using a shovel to threaten the victim?"
		]
	}
}

var onion_tree: Dictionary = {
	"start": {
		"speaker": "Mr. Onion",
		"text": "Detective, the air out here is far more pleasant than your interrogation routines.",
		"choices": [
			{
				"text": "You were seen lingering around the hallway, Mr. Onion. Could you clarify your exact location during the party?",
				"next": "q1_c1_detective"
			},
			{
				"text": "Witnesses saw you around. You entered the office when no one was looking, didn't you?",
				"next": "q1_c2_detective"
			}
		]
	},
	"q1_c1_detective": {
		"speaker": "Detective",
		"text": "You were seen lingering around the hallway, Mr. Onion. Could you clarify your exact location during the party?",
		"next": "q1_c1_reply"
	},
	"q1_c1_reply": {
		"speaker": "Mr. Onion",
		"text": "I spent the entire evening socializing in the party hall. I never set foot inside Pumpkin's office",
		"choices": [
			{
				"text": "We found a page of a document on the floor that we suspect is linked to you. I doubt Mr. Pumpkin would be so careless with such an important piece of paper, wouldn't you say?",
				"next": "q2_doc_detective"
			},
			{
				"text": "We know you entered to take the document, and we have the evidence. Please cooperate with us",
				"next": "q2_cooperate_detective"
			}
		]
	},
	"q2_doc_detective": {
		"speaker": "Detective",
		"text": "We found a page of a document on the floor that we suspect is linked to you. I doubt Mr. Pumpkin would be so careless with such an important piece of paper, wouldn't you say?",
		"next": "q2_doc_reply"
	},
	"q2_doc_reply": {
		"speaker": "Mr. Onion",
		"text": "Clever deduction, Detective. Fine. I went into the office after Chili left, purely to retrieve my business contract",
		"choices": [
			{
				"text": "A man of your stature sees everything in this city, Mr. Onion. Do you happen to know anything further regarding Mr.Chili or Lady Lemon's involvement?",
				"next": "q3_intel_detective"
			},
			{
				"text": "So you were the last person to step into that office, weren't you?",
				"next": "q3_last_detective"
			}
		]
	},
	"q3_intel_detective": {
		"speaker": "Detective",
		"text": "A man of your stature sees everything in this city, Mr. Onion. Do you happen to know anything further regarding Mr.Chili or Lady Lemon's involvement?",
		"next": "win_onion"
	},
	"win_onion": {
		"speaker": "Mr. Onion",
		"text": "I was the last to enter. I saw Mr. Pumpkin resting his head on the desk, so I took my contract. As for the others? Lemon's ring: Pumpkin gave it to her. She used her romantic appeal to manipulate him for years. And Chili? His 'loan partnership' was dirty money laundering from day one. That's all you get from me.",
		"end": true,
		"notes": [
			"Admitted being the last to enter the victim's office.",
			"Holds secret intel on Lady Lemon & Mr. Chili.",
			"Has a clear motive?"
		]
	},
	"q3_last_detective": {
		"speaker": "Detective",
		"text": "So you were the last person to step into that office, weren't you?",
		"next": "lose3_onion"
	},
	"lose3_onion": {
		"speaker": "Mr. Onion",
		"text": "Maybe I was, maybe Lemon was, or maybe Chili was. If you're so sure, just put on the cuffs and let my lawyers tear your badge off!",
		"end": true,
		"notes": [
			"Admitted being the last to enter the victim's office.",
			"(also) Maintained that Lady Lemon returned to the victim's office?"
		]
	},
	"q2_cooperate_detective": {
		"speaker": "Detective",
		"text": "We know you entered to take the document, and we have the evidence. Please cooperate with us",
		"next": "lose2_onion"
	},
	"lose2_onion": {
		"speaker": "Mr. Onion",
		"text": "A man like me... you honestly think I want to cooperate with the police? I believe I'm free to leave now, esteemed Detective",
		"end": true,
		"notes": [
			"Admitted being the last to enter the victim's office.",
			"Refused to cooperate with the investigation"
		]
	},
	"q1_c2_detective": {
		"speaker": "Detective",
		"text": "Witnesses saw you around. You entered the office when no one was looking, didn't you?",
		"next": "lose1_onion"
	},
	"lose1_onion": {
		"speaker": "Mr. Onion",
		"text": "Watch your tongue, Detective!",
		"end": true,
		"notes": [
			"Rattled?",
			"Was the last to enter the victim's office?"
		]
	}
}

func _ready() -> void:
	GameManager.play_bgm("accusation")
	notebook_btn_hub.pressed.connect(func(): Notebook.toggle())
	notebook_btn_diag.pressed.connect(func(): Notebook.toggle())
	back_to_hub_btn.pressed.connect(_return_to_hub)
	accuse_btn.pressed.connect(_go_to_accusation)
	
	lemon_btn.pressed.connect(func(): _start_interrogation("Lady Lemon"))
	chili_btn.pressed.connect(func(): _start_interrogation("Mr. Chili"))
	onion_btn.pressed.connect(func(): _start_interrogation("Mr. Onion"))
	
	next_btn.pressed.connect(_advance_dialogue)
	
	choice_1_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choice_2_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choice_1_btn.add_theme_font_size_override("font_size", 18)
	choice_2_btn.add_theme_font_size_override("font_size", 18)
	
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
		garlic_summary_lbl.text = "Deduction Ready:\n• Pumpkin had zero struggle wounds.\n• Chili threw the shovel down unswung.\n• Onion found Pumpkin already dying before any shovel strike!\n• Champagne glass bore a unique aroma missing from the bottle."
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
	
	if suspect_name == "Lady Lemon":
		_start_lemon_interrogation()
	elif suspect_name == "Mr. Chili":
		_start_chili_interrogation()
	elif suspect_name == "Mr. Onion":
		_start_onion_interrogation()

# --- LADY LEMON DIALOGUE ---
func _start_lemon_interrogation() -> void:
	_display_lemon_node("start")

func _display_lemon_node(node_id: String) -> void:
	current_lemon_node_id = node_id
	var node: Dictionary = lemon_tree[node_id]
	diag_speaker.text = node["speaker"]
	diag_text.text = node["text"]
	
	for c in choice_1_btn.pressed.get_connections():
		choice_1_btn.pressed.disconnect(c.callable)
	for c in choice_2_btn.pressed.get_connections():
		choice_2_btn.pressed.disconnect(c.callable)
	
	if node.has("choices"):
		next_btn.hide()
		choices_box.show()
		var ch: Array = node["choices"]
		choice_1_btn.text = "1. " + ch[0]["text"]
		choice_2_btn.text = "2. " + ch[1]["text"]
		choice_1_btn.pressed.connect(func(): _on_lemon_choice_selected(ch[0]["next"]))
		choice_2_btn.pressed.connect(func(): _on_lemon_choice_selected(ch[1]["next"]))
	else:
		choices_box.hide()
		next_btn.show()
		if node.has("end") and node["end"]:
			next_btn.text = "Finish Questioning ->"
		else:
			next_btn.text = "Next ->"

func _on_lemon_choice_selected(next_node_id: String) -> void:
	_display_lemon_node(next_node_id)

func _on_lemon_next() -> void:
	var node: Dictionary = lemon_tree[current_lemon_node_id]
	if node.has("end") and node["end"]:
		if node.has("notes"):
			for note in node["notes"]:
				GameManager.add_suspect_note("Lady Lemon", note)
		GameManager.mark_interrogated("Lady Lemon")
		_return_to_hub()
	elif node.has("next"):
		_display_lemon_node(node["next"])

# --- MR. CHILI DIALOGUE ---
func _start_chili_interrogation() -> void:
	_display_chili_node("start")

func _display_chili_node(node_id: String) -> void:
	current_chili_node_id = node_id
	var node: Dictionary = chili_tree[node_id]
	diag_speaker.text = node["speaker"]
	diag_text.text = node["text"]
	
	for c in choice_1_btn.pressed.get_connections():
		choice_1_btn.pressed.disconnect(c.callable)
	for c in choice_2_btn.pressed.get_connections():
		choice_2_btn.pressed.disconnect(c.callable)
	
	if node.has("choices"):
		next_btn.hide()
		choices_box.show()
		var ch: Array = node["choices"]
		choice_1_btn.text = "1. " + ch[0]["text"]
		choice_2_btn.text = "2. " + ch[1]["text"]
		choice_1_btn.pressed.connect(func(): _on_chili_choice_selected(ch[0]["next"]))
		choice_2_btn.pressed.connect(func(): _on_chili_choice_selected(ch[1]["next"]))
	else:
		choices_box.hide()
		next_btn.show()
		if node.has("end") and node["end"]:
			next_btn.text = "Finish Questioning ->"
		else:
			next_btn.text = "Next ->"

func _on_chili_choice_selected(next_node_id: String) -> void:
	_display_chili_node(next_node_id)

func _on_chili_next() -> void:
	var node: Dictionary = chili_tree[current_chili_node_id]
	if node.has("end") and node["end"]:
		if node.has("notes"):
			for note in node["notes"]:
				GameManager.add_suspect_note("Mr. Chili", note)
		GameManager.mark_interrogated("Mr. Chili")
		_return_to_hub()
	elif node.has("next"):
		_display_chili_node(node["next"])

# --- MR. ONION DIALOGUE ---
func _start_onion_interrogation() -> void:
	_display_onion_node("start")

func _display_onion_node(node_id: String) -> void:
	current_onion_node_id = node_id
	var node: Dictionary = onion_tree[node_id]
	diag_speaker.text = node["speaker"]
	diag_text.text = node["text"]
	
	for c in choice_1_btn.pressed.get_connections():
		choice_1_btn.pressed.disconnect(c.callable)
	for c in choice_2_btn.pressed.get_connections():
		choice_2_btn.pressed.disconnect(c.callable)
	
	if node.has("choices"):
		next_btn.hide()
		choices_box.show()
		var ch: Array = node["choices"]
		choice_1_btn.text = "1. " + ch[0]["text"]
		choice_2_btn.text = "2. " + ch[1]["text"]
		choice_1_btn.pressed.connect(func(): _on_onion_choice_selected(ch[0]["next"]))
		choice_2_btn.pressed.connect(func(): _on_onion_choice_selected(ch[1]["next"]))
	else:
		choices_box.hide()
		next_btn.show()
		if node.has("end") and node["end"]:
			next_btn.text = "Finish Questioning ->"
		else:
			next_btn.text = "Next ->"

func _on_onion_choice_selected(next_node_id: String) -> void:
	_display_onion_node(next_node_id)

func _on_onion_next() -> void:
	var node: Dictionary = onion_tree[current_onion_node_id]
	if node.has("end") and node["end"]:
		if node.has("notes"):
			for note in node["notes"]:
				GameManager.add_suspect_note("Mr. Onion", note)
		GameManager.mark_interrogated("Mr. Onion")
		_return_to_hub()
	elif node.has("next"):
		_display_onion_node(node["next"])

func _advance_dialogue() -> void:
	if current_suspect == "Lady Lemon":
		_on_lemon_next()
		return
	elif current_suspect == "Mr. Chili":
		_on_chili_next()
		return
	elif current_suspect == "Mr. Onion":
		_on_onion_next()
		return

func _go_to_accusation() -> void:
	get_tree().change_scene_to_file("res://scenes/final_accusation.tscn")
