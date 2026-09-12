extends Control

@onready var bg_rect: TextureRect = $Background
@onready var portrait_rect: TextureRect = $Portrait
@onready var speaker_label: Label = $TextBox/SpeakerLabel
@onready var text_label: Label = $TextBox/TextLabel
@onready var continue_btn: Button = $TextBox/ContinueButton
@onready var skip_btn: Button = $SkipButton
@onready var flash_rect: ColorRect = $FlashRect

var intro_steps := [
	{
		"bg": "res://Assets/Art asset/haven manor/haven manor.png",
		"portrait": "",
		"speaker": "Haven Manor — A Stormy Night",
		"text": "Tonight marks the 25-year reunion of an exclusive circle of friends.\nLaughter and champagne flowed freely behind the grand gates of Haven Manor..."
	},
	{
		"bg": "res://Assets/Art asset/haven manor/haven manor.png",
		"portrait": "res://Assets/Art asset/Characters/pumpkin.png",
		"speaker": "The Host: Mr. Pumpkin",
		"text": "The immensely wealthy and tyrannical farm owner.\nAfter dinner, Mr. Pumpkin retired to his private study to meet each of his guests individually..."
	},
	{
		"bg": "res://Assets/Art asset/haven manor/haven manor.png",
		"portrait": "res://Assets/Art asset/Characters/lemon_dialog.png",
		"speaker": "Guest 1: Lady Lemon",
		"text": "A haughty socialite with a sharp, acidic tongue and lavish tastes.\nShe entered the study for a private conversation..."
	},
	{
		"bg": "res://Assets/Art asset/haven manor/haven manor.png",
		"portrait": "res://Assets/Art asset/Characters/chili.png",
		"speaker": "Guest 2: Mr. Chili",
		"text": "The hot-tempered bank president, puffing nervously on cigars.\nHe had urgent financial business with Pumpkin..."
	},
	{
		"bg": "res://Assets/Art asset/haven manor/haven manor.png",
		"portrait": "res://sprites/dummy.png",
		"speaker": "Guest 3: Mr. Onion",
		"text": "A shadowy underworld broker of few words, lurking in the corridors.\nWhat secrets did he intend to settle tonight?"
	},
	{
		"bg": "res://Assets/Art asset/pumpkin_office/pumpkin_office.png",
		"portrait": "res://Assets/Art asset/Characters/pumpkin_die.png",
		"speaker": "CRIME SCENE",
		"text": "*SCREEEAAAAM!* A piercing cry echoes through the mansion halls!\nMr. Pumpkin lies dead upon the study floor, impaled by a garden shovel!"
	},
	{
		"bg": "res://Assets/Art asset/pumpkin_office/pumpkin_office.png",
		"portrait": "res://Assets/Art asset/Characters/detective.png",
		"speaker": "Inspector Garlic",
		"text": "A brutal murder amidst a circle of wealthy friends.\nYet... look at the body. Zero signs of struggle. Something doesn't add up.\nI must examine the room and catalog every clue."
	}
]

var current_step := 0

func _ready() -> void:
	GameManager.play_bgm("investigation")
	flash_rect.color = Color(1, 1, 1, 0)
	continue_btn.pressed.connect(_on_continue_pressed)
	skip_btn.pressed.connect(_go_to_crime_scene)
	show_step(0)

func show_step(idx: int) -> void:
	current_step = idx
	var data = intro_steps[idx]
	bg_rect.texture = load(data["bg"])
	speaker_label.text = data["speaker"]
	text_label.text = data["text"]
	
	if data["portrait"] != "":
		portrait_rect.texture = load(data["portrait"])
		portrait_rect.show()
	else:
		portrait_rect.hide()
	
	# Lightning flash on murder scene step
	if idx == 5:
		trigger_flash()
	
	if idx >= intro_steps.size() - 1:
		continue_btn.text = "Examine Scene ->"
	else:
		continue_btn.text = "Next ->"

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
