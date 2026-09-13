extends Control

@onready var bg_rect: TextureRect = $Background
@onready var portrait_rect: TextureRect = $Portrait
@onready var text_box: Panel = $TextBox
@onready var speaker_label: Label = $TextBox/SpeakerLabel
@onready var text_label: Label = $TextBox/TextLabel
@onready var continue_btn: TextureButton = $ContinueButton
@onready var skip_btn: Button = $SkipButton
@onready var flash_rect: ColorRect = $FlashRect
@onready var card_container: Control = $CardContainer

@onready var pumpkin_portrait: TextureRect = $CardContainer/CardsHBox/PumpkinCard/PortraitFrame/CardPortrait
@onready var pumpkin_name: Label = $CardContainer/CardsHBox/PumpkinCard/CardName
@onready var lemon_portrait: TextureRect = $CardContainer/CardsHBox/LemonCard/PortraitFrame/CardPortrait
@onready var lemon_name: Label = $CardContainer/CardsHBox/LemonCard/CardName
@onready var chili_portrait: TextureRect = $CardContainer/CardsHBox/ChiliCard/PortraitFrame/CardPortrait
@onready var chili_name: Label = $CardContainer/CardsHBox/ChiliCard/CardName
@onready var onion_portrait: TextureRect = $CardContainer/CardsHBox/OnionCard/PortraitFrame/CardPortrait
@onready var onion_name: Label = $CardContainer/CardsHBox/OnionCard/CardName

var intro_steps := [
	{
		"is_card": false,
		"bg": "res://Assets/Art asset/haven manor/haven manor.png",
		"portrait": "",
		"speaker": "At Haven Manor",
		"text": "Celebrating 25 Years of Friendship..."
	},
	{
		"is_card": true,
		"characters": [
			{
				"name": "Mr. Pumpkin",
				"portrait": "res://Assets/Art asset/Characters/pumpkin.png"
			},
			{
				"name": "Lady Lemon",
				"portrait": "res://Assets/Art asset/Characters/lemon_dialog.png"
			},
			{
				"name": "Mr. Chili",
				"portrait": "res://Assets/Art asset/Characters/chili.png"
			},
			{
				"name": "Mr. Onion",
				"portrait": "res://sprites/dummy.png"
			}
		]
	},
	{
		"is_card": false,
		"bg": "res://Assets/fixed_assets/pumpkin_office new.png",
		"portrait": "",
		"speaker": "CRIME SCENE",
		"text": "*SCREEEAAAAM!* A piercing cry echoes through the mansion halls!\nMr. Pumpkin lies dead upon the study floor, impaled by a garden shovel!"
	},
	{
		"is_card": false,
		"bg": "res://Assets/fixed_assets/pumpkin_office new.png",
		"portrait": "res://Assets/Art asset/Characters/detective.png",
		"speaker": "Inspector Garlic",
		"text": "I need to examine the crime scene first"
	}
]

var current_step := 0

func _ready() -> void:
	GameManager.play_bgm("investigation")
	flash_rect.color = Color(1, 1, 1, 0)
	continue_btn.pressed.connect(_on_continue_pressed)
	skip_btn.pressed.connect(_go_to_crime_scene)
	
	_setup_character_cards()
	show_step(0)

func _setup_character_cards() -> void:
	var chars = intro_steps[1]["characters"]
	pumpkin_portrait.texture = load(chars[0]["portrait"])
	pumpkin_name.text = chars[0]["name"]
	lemon_portrait.texture = load(chars[1]["portrait"])
	lemon_name.text = chars[1]["name"]
	chili_portrait.texture = load(chars[2]["portrait"])
	chili_name.text = chars[2]["name"]
	onion_portrait.texture = load(chars[3]["portrait"])
	onion_name.text = chars[3]["name"]

func show_step(idx: int) -> void:
	current_step = idx
	var data = intro_steps[idx]
	
	if data.get("is_card", false):
		card_container.show()
		text_box.hide()
		portrait_rect.hide()
	else:
		card_container.hide()
		bg_rect.texture = load(data["bg"])
		speaker_label.text = data["speaker"]
		text_label.text = data["text"]
		text_box.show()
		
		if data["portrait"] != "":
			portrait_rect.texture = load(data["portrait"])
			portrait_rect.show()
		else:
			portrait_rect.hide()
	
	# Lightning flash on murder scene step
	if data.get("speaker") == "CRIME SCENE":
		trigger_flash()

func trigger_flash() -> void:
	flash_rect.color = Color(1, 1, 1, 0.85)
	var tween = create_tween()
	tween.tween_property(flash_rect, "color:a", 0.0, 0.4)

func _on_continue_pressed() -> void:
	if current_step < intro_steps.size() - 1:
		show_step(current_step + 1)
	else:
		_go_to_crime_scene()

func _go_to_crime_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/crime_scene.tscn")
