class_name ProcEntity
extends Object

var shader_mat: ShaderMaterial

var rot_speed: float = 1.0
var speed: float = 400.0
var bonus_speed: float = 1.15
var guns: Array[ProcGun] = []

static func make() -> ProcEntity:
	var pe := ProcEntity.new()
	
	pe.shader_mat = SDFBuilder.new().build_shader(Vector3(randf(), randf(), randf()).normalized() * 7./5)
	
	var gun: ProcGun = ProcGun.make()
	var proj: ProcProj = ProcProj.new()
	proj.speed = 600.0
	gun.proj = proj
	pe.guns.append(gun)
	
	return pe


func bind(entity: Entity) -> void:
	entity.proc = self
	entity.team = Global.TEAM.HOSTILE
	entity.guns = []
	entity.guns.resize(guns.size())
	for i in guns.size(): entity.guns[i] = Gun.new()


func preprocess() -> void:
	pass


func process(entity: Entity, delta: float) -> void:
	var target := Global.Game.player as Entity
	
	var p := (target.global_position - Entity.CENTER)*0.35 + target.global_position
	var c := (Entity.CENTER - entity.global_position).normalized()
	var t := (p - entity.global_position)
	var move := (t.normalized() - (c * 0.65)).normalized()
	var dist := t.length()
	var rotate := (target.global_position + target.velocity * 0.0015 * dist - entity.global_position).normalized()
	
	
	var tilt: Vector2 = entity.rotate_and_tilt(rotate, move, delta)
	entity.move_and_bonus(move * (1.0 if dist > 250 else -0.48), -tilt.y, delta)
	
	entity.move_and_slide()
	
	for i in guns.size(): guns[i].process(entity.guns[i], entity, delta)
	
	
	Entity.CENTER_AVG += Vector3(entity.global_position.x, entity.global_position.y, 1)

func update_target(entity: Entity) -> void:
	pass
