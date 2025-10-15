class_name Limbo
extends Node


enum {MAIN_MENU, GAME_MENU, GAME_START}
static var place: int = -1
static var matched: bool = true
static func goto(place_: int) -> void:
	place = place_
	matched = false
	Global.get_tree().change_scene_to_file("res://data/ui/limbo.tscn")
func _process(__: float) -> void:
	if matched: return
	matched = true
	match place:
		-1: return
		GAME_MENU: Global.get_tree().change_scene_to_file("res://data/ui/game_menu.tscn")
		GAME_START: Global.get_tree().change_scene_to_file("res://data/game/gamerunner.tscn")
		_: Global.get_tree().change_scene_to_file("res://data/ui/main_menu.tscn")
