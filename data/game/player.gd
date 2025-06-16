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
	
	#($hurtbox as Area2D).body_entered.connect(_hurtbox_hit)
	state = 1

class ProcPlayer extends ProcEntity:
	static func make() -> ProcPlayer:
		var pp := ProcPlayer.new()
		
		pp.shader_mat = SDFBuilder.new().build_shader_3D(Vector3(0.1, 0.5, 0.5))
		
		pp.rot_speed = 4.8
		pp.speed = 850.0
		
		var main_gun: ProcGun = ProcGun.make()
		var main_proj: ProcProj = ProcProj.make()
		main_gun.proj = main_proj
		
		var sec_gun: ProcGun = ProcGun.make()
		var sec_proj: ProcProj = ProcProj.make()
		sec_gun.proj = sec_proj
		
		main_gun.style = ProcGun.STYLE_GUN
		main_gun.fire_rate = 14
		main_gun.inaccuracy = 0.2
		main_proj.speed = 900.0
		main_proj.damage = 1.0
		
		sec_gun.style = ProcGun.STYLE_REPEATER
		sec_gun.fire_rate = 0.7
		sec_gun.style_data_i = 3
		sec_gun.style_data_f = 100
		sec_gun.add_modifier(ProcGun.MOD_DUAL, 12.0)
		sec_gun.inaccuracy = 0.0
		sec_proj.speed = 1600.0
		sec_proj.damage = 2.0
		sec_proj.depth = 1.0
		
		pp.guns.append(main_gun)
		pp.guns.append(sec_gun)
		
		#var temp_gun := ProcGun.make()
		#var temp_proj := ProcProj.make()
		#temp_gun.proj = temp_proj
		#temp_gun.style = ProcGun.STYLE_GUN
		#temp_gun.fire_rate = 1.0
		#temp_gun.inaccuracy = 0.0
		#temp_proj.speed = 900
		#temp_proj.damage = 1.0
		#temp_proj.depth = 10
		#pp.guns.append(temp_gun)
		
		
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
