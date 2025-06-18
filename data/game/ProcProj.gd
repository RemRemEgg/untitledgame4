class_name ProcProj
extends RefCounted

## bullet types
# default
# partial lazer
# mine
# 
## bullet modifiers
# <none>
# explosive
# homing
# split
# pierce
# bounce
# status effect
# stunning
# slow
# vamp
# movements modifiers
# 

var shader_mat: ShaderMaterial
var psqp: PhysicsShapeQueryParameters2D

var max_health: float = 4.0
var scale: float = 1.0
var depth: float = 2.0
var speed: float = 800.0
var damage: float = 4.0


static func make() -> ProcProj:
	var pp: ProcProj = ProcProj.new()
	
	pp.shader_mat = SDFBuilder.new().build_shader_2D((Vector3(randf(), randf(), randf()) - Vector3(0.1, 0.1, 0.1)).normalized() * 7./12)
	pp.psqp = PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	pp.psqp.shape = shape
	
	return pp


func make_projectile(pos: Vector2, dir: float, ownr: Entity) -> Projectile:
	var proj := Global.SCN_PROJECTILE.instantiate() as Projectile
	proj.proc = self
	proj.global_position = pos
	proj.rotation = dir
	proj.ownr = ownr
	proj.can_hurt = ~ownr.team
	
	proj.health = max_health
	proj.scale *= scale
	proj.speed = speed
	proj.damage = damage
	proj.depth = 0.0
	
	
	Global.Game.projectiles.add_child(proj)
	return proj



const STEP_SIZE: float = 12.0
func process(proj: Projectile, delta: float) -> void:
	if proj.health <= 0.0: return
	
	var mdot := speed  * delta
	var dir := Vector2.RIGHT.rotated(proj.rotation)
	while mdot >= 0.0:
		proj.global_position += dir * minf(mdot, STEP_SIZE)
		mdot -= STEP_SIZE
		psqp.transform = proj.global_transform
		var hits := proj.get_world_2d().direct_space_state.intersect_shape(psqp)
		for hit in hits:
			var colc := hit["collider"] as PhysicsBody2D
			if colc is Entity: if !process_collision(proj, colc as Entity): return
	
	proj.mesh.global_position = Entity.up_dim(proj.global_position)
	proj.mesh.rotation.y = -proj.rotation
	
	proj.health -= delta
	if proj.health <= 0.0: kill(proj)


func process_collision(proj: Projectile, entity: Entity) -> bool:
	if !(proj.can_hurt & entity.team): return true
	Entity.DAMAGE_DATA[0] = proj.damage * (1.0 + pow(0.9, proj.depth + 5.0))
	proj.depth += entity._process_damage() * 0.5
	if proj.depth >= depth:
		kill(proj)
		return false
	return true


func kill(proj: Projectile) -> void:
	proj.health = -10.0
	var parent := proj.mesh.get_parent()
	if parent: parent.remove_child(proj.mesh)
	proj.mesh.queue_free()
	proj.queue_free()
