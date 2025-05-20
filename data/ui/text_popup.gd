class_name TextPopup
extends Node2D

var time: float = 0.0
var style: int = 0
var dir: Vector2
var text: String

static func instant(text: String, pos: Vector2, style: int = 0) -> TextPopup:
	var pop: TextPopup = Global.SCN_TEXT_POPUP.instantiate() as TextPopup
	(pop.get_child(0) as Label).text = text
	pop.text = text
	pop.global_position = pos
	pop.style = style
	Global.Game.popups.add_child(pop)
	
	match style:
		0:
			pop.modulate = Color(0.9, 0.5, 0.45, 1.0)
			pop.dir = Vector2.LEFT.rotated(randf() * PI * 2)
		1:
			pop.modulate = Color(1.0, 0.4, 0.2, 1.0)
			pop.dir = Vector2.LEFT.rotated(randf() * PI * 2) * 1.2
	
	return pop


func _process(delta: float) -> void:
	time += delta
	
	match style:
		-1:
			if time > 2.0: queue_free()
		0, 1:
			position += dir * delta * 16.0 / (time + 0.15)
			scale = Vector2.ONE * minf(2.4025 - (2*time - 1.45)**2, 1.0)
			if time > 1.5: queue_free()
