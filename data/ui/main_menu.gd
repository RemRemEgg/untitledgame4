extends Control


@onready var start_game: Button = $margin_container/h_box_container/v_box_container/start_game as Button
@onready var sdf_test: Button = $margin_container/h_box_container/v_box_container/sdf_test as Button

func _ready() -> void:
	Global.load_status = -1
	Global.toggle_console.call_deferred()
	start_game.button_up.connect(_start_game_pressed)
	sdf_test.button_up.connect(_sdf_test)

func _process(_delta: float) -> void:pass

func _start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://data/game/gamerunner.tscn")

func _sdf_test() -> void:
	get_tree().change_scene_to_file("res://sdf_test.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_0: start_game.button_up.emit()
