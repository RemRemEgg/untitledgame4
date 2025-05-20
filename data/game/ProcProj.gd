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


var temp_mod: int = 0

var pierce: int = 0
var speed: float = 800.0
var damage: float = 4.0


static func make() -> ProcProj:
	var pp: ProcProj = ProcProj.new()
	return pp


func make_projectile(pos: Vector2, dir: float, hurt_team: int) -> Projectile:
	var proj := Global.SCN_PROJECTILE.instantiate() as Projectile
	proj.proc = self
	proj.global_position = pos
	proj.rotation = dir
	proj.can_hurt = hurt_team
	Global.Game.projectiles.add_child(proj)
	
	proj.speed = speed
	proj.damage = damage
	proj.pierce = pierce
	
	
	return proj



func process(proj: Projectile, delta: float) -> void:
	proj.velocity = Vector2.RIGHT.rotated(proj.rotation) * speed
	proj.move_and_slide()
	proj.mesh.global_position = Entity.up_dim(proj.global_position)
	proj.mesh.rotation.y = PI/2-proj.rotation
	
	proj.health -= delta
	if proj.health <= 0.0: kill(proj)


func kill(proj: Projectile) -> void:
	var parent := proj.mesh.get_parent()
	if parent: parent.remove_child(proj.mesh)
	proj.mesh.queue_free()
	proj.queue_free()


func process_collision(proj: Projectile, entity: Entity) -> void:
	if !(proj.can_hurt & entity.team): return
	Entity.DAMAGE_DATA[0] = proj.damage
	entity._process_damage()
	
	proj.pierce -= 1
	if proj.pierce < 0: kill(proj)
