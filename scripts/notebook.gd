extends CanvasLayer

@onready var notebook_tabs: TabContainer = $Notebook
@onready var evidence_grid: GridContainer = $Notebook/Evidence/EvidenceGrid
@onready var item_name: Label = $Notebook/Evidence/ItemName
@onready var item_desc: RichTextLabel = $Notebook/Evidence/ItemDesc

@onready var profile_grid: GridContainer = $Notebook/Profiles/ProfileGrid
@onready var profile_name: Label = $Notebook/Profiles/ProfileName
@onready var profile_desc: RichTextLabel = $Notebook/Profiles/ProfileDesc

@onready var close_btn_evidence: Button = $Notebook/Evidence/CloseButton
@onready var close_btn_profiles: Button = $Notebook/Profiles/CloseButton

# Backward compatibility properties
var evidence_counter: int = 0

var _selected_suspect_name: String = ""
var _selected_evidence_id: String = ""

# Track card frame references for suspect and evidence buttons
var _profile_cards: Dictionary = {}
var _evidence_cards: Dictionary = {}

func _ready() -> void:
	hide()
	GameManager.evidence_collected.connect(_on_evidence_collected)
	GameManager.suspect_updated.connect(_on_suspect_updated)
	
	if close_btn_evidence:
		close_btn_evidence.pressed.connect(close)
	if close_btn_profiles:
		close_btn_profiles.pressed.connect(close)
	
	_style_scrollbars()
	_setup_profile_buttons()

func _style_scrollbars() -> void:
	var scrollbars: Array[VScrollBar] = []
	if profile_desc:
		scrollbars.append(profile_desc.get_v_scroll_bar())
	if item_desc:
		scrollbars.append(item_desc.get_v_scroll_bar())
	
	var sb_grab = StyleBoxFlat.new()
	sb_grab.bg_color = Color(0.098, 0.098, 0.098, 1.0)
	sb_grab.set_border_width_all(1)
	sb_grab.border_color = Color(0.098, 0.098, 0.098, 1.0)
	
	var sb_grab_hl = StyleBoxFlat.new()
	sb_grab_hl.bg_color = Color(0.25, 0.25, 0.25, 1.0)
	sb_grab_hl.set_border_width_all(1)
	sb_grab_hl.border_color = Color(0.098, 0.098, 0.098, 1.0)
	
	var sb_grab_pr = StyleBoxFlat.new()
	sb_grab_pr.bg_color = Color(0.098, 0.098, 0.098, 1.0)
	sb_grab_pr.set_border_width_all(2)
	sb_grab_pr.border_color = Color(1, 0.961, 0.863, 1.0)
	
	var sb_track = StyleBoxFlat.new()
	sb_track.bg_color = Color(0.88, 0.83, 0.73, 0.5)
	sb_track.set_border_width_all(1)
	sb_track.border_color = Color(0.65, 0.60, 0.52, 0.5)
	
	for vs in scrollbars:
		if vs:
			vs.custom_minimum_size = Vector2(6, 0)
			vs.add_theme_stylebox_override("grabber", sb_grab)
			vs.add_theme_stylebox_override("grabber_highlight", sb_grab_hl)
			vs.add_theme_stylebox_override("grabber_pressed", sb_grab_pr)
			vs.add_theme_stylebox_override("scroll", sb_track)

func _setup_profile_buttons() -> void:
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
				
				var card_data = _setup_card_frame(btn, s_name, true)
				_connect_card_signals(btn, card_data, func(): _select_suspect(s_name))

func _setup_card_frame(btn: TextureButton, key: String, is_suspect: bool) -> Dictionary:
	var card_dict = _profile_cards if is_suspect else _evidence_cards
	if card_dict.has(key):
		return card_dict[key]
	
	var bg = btn.get_node_or_null("CardBg") as Panel
	if bg == null:
		bg = Panel.new()
		bg.name = "CardBg"
		bg.show_behind_parent = true
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		btn.add_child(bg)
	
	var border = btn.get_node_or_null("CardBorder") as Panel
	if border == null:
		border = Panel.new()
		border.name = "CardBorder"
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		btn.add_child(border)
	
	var badge = btn.get_node_or_null("CardBadge") as Label
	if badge == null:
		badge = Label.new()
		badge.name = "CardBadge"
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		badge.offset_left = 72
		badge.offset_top = 2
		badge.offset_right = 92
		badge.offset_bottom = 22
		badge.add_theme_color_override("font_color", Color(0.098, 0.098, 0.098, 1.0))
		badge.add_theme_font_override("font", load("res://fonts/Mister Pixel Regular.otf"))
		badge.add_theme_font_size_override("font_size", 14)
		badge.text = "★"
		badge.visible = false
		btn.add_child(badge)
	
	var card_data = {
		"btn": btn,
		"bg": bg,
		"border": border,
		"badge": badge,
		"key": key,
		"is_suspect": is_suspect
	}
	card_dict[key] = card_data
	_apply_card_state(card_data, "normal")
	return card_data

func _connect_card_signals(btn: TextureButton, card_data: Dictionary, on_press: Callable) -> void:
	for conn in btn.pressed.get_connections():
		btn.pressed.disconnect(conn.callable)
	for conn in btn.mouse_entered.get_connections():
		btn.mouse_entered.disconnect(conn.callable)
	for conn in btn.mouse_exited.get_connections():
		btn.mouse_exited.disconnect(conn.callable)
	for conn in btn.button_down.get_connections():
		btn.button_down.disconnect(conn.callable)
	for conn in btn.button_up.get_connections():
		btn.button_up.disconnect(conn.callable)
	
	btn.pressed.connect(on_press)
	
	btn.mouse_entered.connect(func():
		if not _is_card_selected(card_data):
			_apply_card_state(card_data, "hover")
	)
	btn.mouse_exited.connect(func():
		if _is_card_selected(card_data):
			_apply_card_state(card_data, "selected")
		else:
			_apply_card_state(card_data, "normal")
	)
	btn.button_down.connect(func():
		_apply_card_state(card_data, "pressed")
	)
	btn.button_up.connect(func():
		if _is_card_selected(card_data):
			_apply_card_state(card_data, "selected")
		else:
			_apply_card_state(card_data, "hover")
	)

func _is_card_selected(card_data: Dictionary) -> bool:
	if card_data.is_suspect:
		return card_data.key == _selected_suspect_name
	else:
		return card_data.key == _selected_evidence_id

func _apply_card_state(card_data: Dictionary, state: String) -> void:
	var bg: Panel = card_data.bg
	var border: Panel = card_data.border
	var badge: Label = card_data.badge
	var btn: TextureButton = card_data.btn
	
	var style_bg = StyleBoxFlat.new()
	var style_border = StyleBoxFlat.new()
	style_border.bg_color = Color(0, 0, 0, 0)
	
	match state:
		"normal":
			style_bg.bg_color = Color(0.922, 0.886, 0.804, 1.0)
			style_border.border_color = Color(0.098, 0.098, 0.098, 1.0)
			style_border.set_border_width_all(1)
			btn.modulate = Color(1, 1, 1, 1)
			badge.visible = false
		"hover":
			style_bg.bg_color = Color(0.875, 0.831, 0.737, 1.0)
			style_border.border_color = Color(0.098, 0.098, 0.098, 1.0)
			style_border.set_border_width_all(2)
			btn.modulate = Color(1, 1, 1, 1)
			badge.visible = false
		"pressed":
			# Pressed state MUST be black / #191919 as requested
			style_bg.bg_color = Color(0.098, 0.098, 0.098, 1.0)
			style_border.border_color = Color(1, 0.961, 0.863, 1.0)
			style_border.set_border_width_all(2)
			btn.modulate = Color(1, 0.961, 0.863, 1.0)
			badge.visible = false
		"selected":
			style_bg.bg_color = Color(0.860, 0.810, 0.710, 1.0)
			style_border.border_color = Color(0.098, 0.098, 0.098, 1.0)
			style_border.set_border_width_all(3)
			btn.modulate = Color(1, 1, 1, 1)
			badge.visible = true
	
	bg.add_theme_stylebox_override("panel", style_bg)
	border.add_theme_stylebox_override("panel", style_border)

func _refresh_suspect_card_visuals() -> void:
	for key in _profile_cards:
		var card = _profile_cards[key]
		if key == _selected_suspect_name:
			_apply_card_state(card, "selected")
		else:
			_apply_card_state(card, "normal")

func _refresh_evidence_card_visuals() -> void:
	for key in _evidence_cards:
		var card = _evidence_cards[key]
		if key == _selected_evidence_id:
			_apply_card_state(card, "selected")
		else:
			_apply_card_state(card, "normal")

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
		item_name.text = "No Evidence Collected"
		item_desc.text = "[color=#5A5243]Explore the crime scene and examine suspicious objects to discover clues.[/color]"
	_select_suspect("Mr. Pumpkin")

func close() -> void:
	visible = false

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
		if _selected_suspect_name != "":
			_select_suspect(_selected_suspect_name)

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
			
			var card_data = _setup_card_frame(btn, ev_id, false)
			_connect_card_signals(btn, card_data, func(): _select_evidence(ev_id))
		else:
			btn.hide()
	
	_refresh_evidence_card_visuals()

func _select_evidence(ev_id: String) -> void:
	_selected_evidence_id = ev_id
	_refresh_evidence_card_visuals()
	if GameManager.evidence_db.has(ev_id):
		var data = GameManager.evidence_db[ev_id]
		item_name.text = data.name
		item_desc.text = "[b]CLUE DESCRIPTION:[/b]\n\n" + data.desc

func refresh_profiles() -> void:
	pass

func _select_suspect(s_name: String) -> void:
	_selected_suspect_name = s_name
	_refresh_suspect_card_visuals()
	if GameManager.suspect_db.has(s_name):
		var data = GameManager.suspect_db[s_name]
		profile_name.text = s_name + "\n[" + data.role + "]"
		var desc: String = "[b]STATEMENT & BACKGROUND:[/b]\n"
		desc += data.traits + "\n\n"
		desc += "[b]INTERROGATION NOTES:[/b]\n"
		if data.notes.size() == 0:
			desc += "[color=#5A5243]• No testimony or contradictions gathered yet.[/color]"
		else:
			for note in data.notes:
				desc += "• " + note + "\n\n"
		profile_desc.text = desc

func _on_close_button_pressed() -> void:
	close()

# Compatibility methods for external scripts
func add_evidence(name_or_id: String) -> void:
	evidence_counter += 1
	if not GameManager.has_evidence(name_or_id):
		GameManager.collect_evidence(name_or_id)
	refresh_evidence()

func add_profile_info(profile: String, info: String) -> void:
	if GameManager.suspect_db.has(profile):
		if not GameManager.suspect_db[profile]["notes"].has(info):
			GameManager.suspect_db[profile]["notes"].append(info)
			GameManager.suspect_updated.emit(profile)
