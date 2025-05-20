class_name Camera
extends Camera3D

var ppos: Vector2 = Vector2.ZERO
@onready var debug_draw: Sprite3D = $debug_draw as Sprite3D

func _ready() -> void:
	debug_draw.scale = Vector3.ONE / (25*12.0)

func v_min(a: Vector2, b: Vector2) -> Vector2:
	return Vector2(min(a.x, b.x), min(a.y, b.y))

func _process(_delta: float) -> void:
	const SCALE: float = 12.0
	#global_position = Vector3(Global.Game.player.global_position.x / SCALE, 35, Global.Game.player.global_position.y/SCALE)
	var direction: Vector2 = Global.Game.player.global_position - ppos
	var dls := direction.length_squared()
	if dls > 800**2 || dls < -1:
		ppos += direction
		global_position = Vector3(ppos.x / SCALE, 25, ppos.y/SCALE)
		return
	dls = sqrt(dls)
	direction *= (dls + 00) / (dls + 200)
	ppos += v_min((direction.abs() * _delta * 60.0), (Global.Game.player.global_position - ppos).abs()) * direction.sign()
	global_position = Vector3(ppos.x / SCALE, 25, ppos.y/SCALE)
	Global.Game.debug_camera.global_position = Entity.down_dim(global_position)

func warp(pos: Vector2) -> void: ppos += pos
