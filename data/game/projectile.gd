class_name Projectile
extends CharacterBody2D

var proc: ProcProj

var mesh: MeshInstance3D

var can_hurt: int

var pierce: int = 0
var speed: float = 1000.0
var damage: float = 4.0
var health: float = 20.0

#static func make(pos: Vector2, dir: float, hurt_team: int) -> Projectile:
	#var proj := Global.SCN_PROJECTILE.instantiate() as Projectile
	#proj.global_position = pos
	#proj.rotation = dir
	#proj.can_hurt = hurt_team
	#Global.Game.projectiles.add_child(proj)
	#
	##proj.speed = data.speed
	##proj.damage = data.damage
	##proj.pierce = data.pierce
	#
	#return proj



func _ready() -> void:
	mesh = $mesh_instance_3d as Node3D
	remove_child(mesh)
	Global.Game.render.add_child(mesh)
	mesh.global_position = Entity.up_dim(global_position)
	
	health = 4.0

func _process(delta: float) -> void:
	proc.process(self, delta)
	#velocity = Vector2.RIGHT.rotated(rotation) * speed
	#move_and_slide()
	#mesh.global_position = up_dim(global_position)
	#
	#health -= delta
	#if health <= 0.0: kill()

func _process_collision(entity: Entity) -> void:
	proc.process_collision(self, entity)
	
	#if !(can_hurt & entity.team): return
	#DAMAGE_DATA[0] = damage
	#entity._process_damage()
	#
	#pierce -= 1
	#if pierce < 0: kill()
