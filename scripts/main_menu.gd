extends Control

@onready var play_btn: Button = $VBoxContainer/PlayButton
@onready var credits_btn: Button = $VBoxContainer/CreditsButton
@onready var quit_btn: Button = $VBoxContainer/QuitButton
@onready var credits_panel: Panel = $CreditsPanel
@onready var credits_close: Button = $CreditsPanel/CloseButton

func _ready() -> void:
	GameManager.play_bgm("menu")
	GameManager.reset_game()
	credits_panel.hide()
	
	play_btn.pressed.connect(_on_play_pressed)
	credits_btn.pressed.connect(_on_credits_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	credits_close.pressed.connect(func(): credits_panel.hide())

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func _on_credits_pressed() -> void:
	credits_panel.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
