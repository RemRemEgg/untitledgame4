class_name Player
extends Entity

##Ships     ++       +         -
# (GCannon) MDamage  Focus   - Health
# (Tank   ) Health   StatEff - Focus
# (Sniper ) Critx    MDamage - StatEff
# (Booster) StatEff  Critx   - MDamage
# (AoE/CC ) Focus    Health  - Critx

##Tree
# MDamage SDamage Pierce
# Health  Shield  Vamp
# Critx   Critp   Execute
# StatEff ?       MSFirerate
# Focus   Special Ultimate

##Artifacts
# B.Speed
# Speed Dodge
# Thorns Bounce
# Handling Execution

var stats: Array[float] = [
	10, 50, 0,
	100, 20, 0,
	1.7, .05, 0,
	0, 0, 10,
	0, 0, 0
]
class STAT: enum {
	MDAMAGE, SDAMAGE, PIERCE,
	HEALTH, SHIELD, VAMP,
	CRITX, CRITP, EXECUTE,
	STATEFF, _dne, MSFRATE,
	FOCUS, SPECIAL, ULTIMATE
}
static var STAT_NAMES: PackedStringArray = ["MDAMAGE", "SDAMAGE", "PIERCE", "HEALTH", "SHIELD", "VAMP", "CRITX", "CRITP", "EXECUTE", "STATEFF", "_dne", "MSFRATE", "FOCUS", "SPECIAL", "ULTIMATE"]
static func string_to_stat(name: String) -> int: return STAT_NAMES.find(name)



func _ready() -> void:
	ProcPlayer.make().bind(self)
	
	var steal := Global.SCN_ENTITY.instantiate() as Entity
	mesh = steal.get_node("mesh")
	mesh.get_parent().remove_child(mesh)
	steal.queue_free()
	mesh.owner = null
	mesh.material_override = proc.shader_mat
	Global.Game.render.add_child(mesh)
	
	($hurtbox as Area2D).body_entered.connect(_hurtbox_hit)
	state = 1

class ProcPlayer extends ProcEntity:
	static func make() -> ProcPlayer:
		var pp := ProcPlayer.new()
		
		pp.shader_mat = SDFBuilder.new().build_shader(Vector3(0.1, 0.5, 0.5))
		
		pp.rot_speed = 4.8
		pp.speed = 1000.0
		
		var pg: ProcGun = ProcGun.make()
		var ppo: ProcProj = ProcProj.make()
		ppo.speed = 1200.0
		pg.proj = ppo
		pg.style = ProcGun.STYLE_REPEATER
		pg.fire_rate = 2.
		pg.style_data_i = 60
		pg.style_data_f = 300
		pg.inaccuracy = 0.0
		#pg.style = ProcGun.STYLE_GUN
		#pg.fire_rate = 10
		#pg.add_modifier(ProcGun.MOD_SPREAD, 5.0)
		#pg.inaccuracy = 0.0
		pp.guns.append(pg)
		
		
		return pp
	
	func bind(entity: Entity) -> void:
		var player := entity as Player
		player.proc = self
		player.team = Global.TEAM.FRIENDLY
		player.health = 100000
		player.guns = []
		player.guns.resize(guns.size())
		
		player.guns = []
		player.guns.resize(guns.size())
		for i in guns.size(): player.guns[i] = Gun.new()
	
	
	func process(entity: Entity, delta: float) -> void:
		var player := entity as Player
		var move := Input.get_vector(&"left", &"right", &"up", &"down")
	
		var tilt: Vector2 = player.rotate_and_tilt(player.get_global_mouse_position() - player.global_position, move, delta)
		player.move_and_bonus(move, (400.0 if Input.is_action_pressed("boost") else 0.0)-tilt.y, delta)
		
		player.move_and_slide()
		
		for i in guns.size(): guns[i].process(player.guns[i], player, delta)
