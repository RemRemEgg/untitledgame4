extends Control

@onready var start_game: Button = $margin_container/flow_container/start_game

func _ready() -> void:
	start_game.button_up.connect(func(): get_tree().change_scene_to_file("res://data/game/gamerunner.tscn"))
