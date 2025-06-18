extends Control



@onready var menus: HBoxContainer = $margin/menus as HBoxContainer

@onready var title: VBoxContainer = $margin/menus/title as VBoxContainer
@onready var saves: VBoxContainer = $margin/menus/saves as VBoxContainer
@onready var settings: VBoxContainer = $margin/menus/settings as VBoxContainer

@onready var start_game: Button = $margin/menus/title/start_game as Button
@onready var sdf_test: Button = $margin/menus/title/sdf_test as Button
@onready var settings_btn: Button = $margin/menus/title/settings as Button





func _ready() -> void:
	set_depth(1)
	Global.load_status = -1
	Global.toggle_console.call_deferred()
	
	start_game.button_up.connect(_start_game_pressed)
	settings_btn.button_up.connect(_settings_pressed)
	sdf_test.button_up.connect(_sdf_test)
	
	var i: int = 0
	for save in saves.get_children():
		save.button_up.connect(_save_file_pressed.bind(i))
		i += 1

func set_depth(depth: int) -> void:
	if depth < 1: depth = 1
	while menus.get_children().size() > depth: menus.remove_child(menus.get_child(-1))



func _start_game_pressed() -> void:
	set_depth(1)
	menus.add_child(saves)

func _settings_pressed() -> void:
	set_depth(1)
	menus.add_child(settings)

func _save_file_pressed(_id: int) -> void:
	get_tree().change_scene_to_file("res://data/ui/game_menu.tscn")


func _sdf_test() -> void:
	get_tree().change_scene_to_file("res://sdf_test.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_1 && event.get_modifiers_mask() & KEY_MASK_CTRL != 0: saves.get_child(0).button_up.emit()
