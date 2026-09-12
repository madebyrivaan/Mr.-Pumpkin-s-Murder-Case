extends CanvasLayer

@onready var notebook_tabs: TabContainer = $Notebook
@onready var evidence_grid: GridContainer = $Notebook/Evidence/EvidenceGrid
@onready var item_name: Label = $Notebook/Evidence/ItemName
@onready var item_desc: Label = $Notebook/Evidence/ItemDesc

@onready var profile_grid: GridContainer = $Notebook/Profiles/ProfileGrid
@onready var profile_name: Label = $Notebook/Profiles/ProfileName
@onready var profile_desc: Label = $Notebook/Profiles/ProfileDesc

func _ready() -> void:
	hide()
	GameManager.evidence_collected.connect(_on_evidence_collected)
	GameManager.suspect_updated.connect(_on_suspect_updated)
	
	# Connect profile buttons
	var suspects := ["Mr. Pumpkin", "Lady Lemon", "Mr. Chili", "Mr. Onion"]
	var p_buttons := profile_grid.get_children()
	for i in range(p_buttons.size()):
		if i < suspects.size():
			var s_name = suspects[i]
			var btn: TextureButton = p_buttons[i]
			if GameManager.suspect_db.has(s_name):
				var icon_path: String = GameManager.suspect_db[s_name]["icon"]
				btn.texture_normal = load(icon_path)
				btn.ignore_texture_size = false
				btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
				# Disconnect previous pressed signals if any
				for conn in btn.pressed.get_connections():
					btn.pressed.disconnect(conn.callable)
				btn.pressed.connect(func(): _select_suspect(s_name))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			close()

func open() -> void:
	show()
	refresh_evidence()
	refresh_profiles()
	if GameManager.collected_evidence.size() > 0:
		_select_evidence(GameManager.collected_evidence[0])
	else:
		item_name.text = "No Evidence"
		item_desc.text = "Click around the crime scene to discover clues."
	_select_suspect("Mr. Pumpkin")

func close() -> void:
	self.visible = false;

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func _on_evidence_collected(_id: String) -> void:
	if visible:
		refresh_evidence()

func _on_suspect_updated(_name: String) -> void:
	if visible:
		refresh_profiles()

func refresh_evidence() -> void:
	var buttons := evidence_grid.get_children()
	var collected := GameManager.collected_evidence
	
	for i in range(buttons.size()):
		var btn: TextureButton = buttons[i]
		if i < collected.size():
			var ev_id = collected[i]
			var data = GameManager.evidence_db[ev_id]
			btn.texture_normal = load(data.icon)
			btn.ignore_texture_size = false
			btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			btn.show()
			for conn in btn.pressed.get_connections():
				btn.pressed.disconnect(conn.callable)
			btn.pressed.connect(func(): _select_evidence(ev_id))
		else:
			btn.hide()

func _select_evidence(ev_id: String) -> void:
	if GameManager.evidence_db.has(ev_id):
		var data = GameManager.evidence_db[ev_id]
		item_name.text = data.name
		item_desc.text = data.desc

func refresh_profiles() -> void:
	pass

func _select_suspect(s_name: String) -> void:
	if GameManager.suspect_db.has(s_name):
		var data = GameManager.suspect_db[s_name]
		profile_name.text = s_name + "\n[" + data.role + "]"
		var desc: String = "Bio: " + data.traits + "\n\nNotes:\n"
		if data.notes.size() == 0:
			desc += "- No testimony or contradictions gathered yet."
		else:
			for note in data.notes:
				desc += "• " + note + "\n"
		profile_desc.text = desc

func _on_close_button_pressed() -> void:
	close()
