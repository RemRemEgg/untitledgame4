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
static func string_to_stat(name_: String) -> int: return STAT_NAMES.find(name_)



func _ready() -> void:
	proc = ProcPlayer.create(0,0)
	
	mesh = MeshInstance3D.new()
	Global.Game.render.add_child(mesh)
	mesh.mesh = proc.mesh
	team = proc.team
	collision_layer |= ~team & 0b1111
	
	health = 100000
	guns = []
	guns.resize(proc.guns.size())
	for i in guns.size(): guns[i] = Gun.new()

class ProcPlayer extends ProcEntity:
	static func create(__, ___) -> ProcPlayer:
		var pp := ProcPlayer.new()
		pp.team = 0b0001
		
		pp.shader_mat = SDFBuilder.new().build_shader_3D(Vector3(randf(), randf(), randf()).normalized() * 7./5)
		var mesh_ := PlaneMesh.new()
		mesh_.size = Vector2(6.0, 6.0)
		pp.mesh = mesh_
		pp.mesh.material = pp.shader_mat
		
		var main_gun: ProcGun = ProcGun.create()
		var main_proj: ProcProj = ProcProj.create()
		main_gun.proj = main_proj
		
		var sec_gun: ProcGun = ProcGun.create()
		var sec_proj: ProcProj = ProcProj.create()
		sec_gun.proj = sec_proj
		
		main_gun.style = ProcGun.STYLE_GUN
		main_gun.fire_rate = 7
		main_gun.inaccuracy = 0.12
		main_gun.front_dist = 14.0
		main_proj.speed = 900.0
		main_proj.damage = 1.0
		#main_proj.add_modifier(ProcProj.MOD_SIN, [20.0])
		
		sec_gun.style = ProcGun.STYLE_GUN
		sec_gun.fire_rate = 0.7
		sec_gun.add_modifier(ProcGun.MOD_LINE, [2, 16.0])
		sec_gun.inaccuracy = 0.0
		sec_gun.front_dist = 12.0
		sec_proj.speed = 1600.0
		sec_proj.damage = 4.0
		sec_proj.depth = 3.0
		sec_proj.add_modifier(ProcProj.MOD_DECELERATE, [1.0])
		
		pp.guns.append(main_gun)
		pp.guns.append(sec_gun)
		
		pp.rot_speed = 4.8
		pp.speed = 850.0
		
		return pp
	
	func process(ent: Entity, delta: float) -> void:
		var player := ent as Player
		var move := Input.get_vector(&"left", &"right", &"up", &"down")
		var tilt: Vector2 = player.rotate_and_tilt(player.get_global_mouse_position() - player.global_position, move, delta)
		player.move_and_bonus(move, (400.0 if Input.is_action_pressed("boost") else 0.0)-tilt.y, delta)
		
		player.move_and_slide()
		
		for i in guns.size(): guns[i].process(player.guns[i], player.global_transform, player, delta)
		
		ent.mesh.global_position = Entity.up_dim(ent.global_position)
		ent.mesh.rotation = Vector3(lerpf(ent.mesh.rotation.x, ent.rotlerp.x, delta*3), -ent.rotation, lerpf(ent.mesh.rotation.z, ent.rotlerp.y, delta*5))
		ent.hurt_time -= delta
		if ent.hurt_time < 0: ent.mesh.set_instance_shader_parameter("hurt", false)
