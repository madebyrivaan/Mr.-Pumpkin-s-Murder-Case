extends Control

@onready var play_btn: Button = $PlayButton

func _ready() -> void:
	GameManager.play_bgm("menu")
	GameManager.reset_game()
	play_btn.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro.tscn")
