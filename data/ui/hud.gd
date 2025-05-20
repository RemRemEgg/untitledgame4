extends CanvasLayer

var udp: float = 0.0
@onready var fps: Label = $margin_container/fps as Label
var ppos: Vector2 = Vector2.ZERO

func _ready() -> void: pass

static var DEBUG_TEXT: StringName = \
&"""\
FPS: %s
Wave: %+.1f/%s/%s
Speed: %.2f u/s
"""

func _process(dx: float) -> void:
	if !Global.DEBUG: return
	udp += dx
	if udp > 0.1:
		fps.text = DEBUG_TEXT % [\
		Engine.get_frames_per_second(),\
		Global.Game.wave_delay, Global.Game.wave_total, Global.Game.wave_count,\
		(Global.Game.player.position - ppos).length()/udp\
		]
		ppos = Global.Game.player.position
		udp = 0
