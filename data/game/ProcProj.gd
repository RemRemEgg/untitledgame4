class_name ProcProj
#extends Node2D
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

static var count: int = 0

var psqp: PhysicsShapeQueryParameters2D
var shape: CircleShape2D
var mesh: PlaneMesh
var shader_mat: ShaderMaterial

var health: float = 4.0
var scale: float = 1.0
var depth: float = 2.0
var speed: float = 800.0
var damage: float = 4.0



static func create() -> ProcProj:
	var pp: ProcProj = ProcProj.new()
	
	pp.shader_mat = SDFBuilder.new().build_shader_2D((Vector3(randf(), randf(), randf()) - Vector3(0.1, 0.1, 0.1)).normalized() * 7./12)
	var m := PlaneMesh.new()
	m.size = Vector2(4.0, 2.0)
	m.center_offset = Vector3(-0.5, 0.0, 0.0)
	m.material = pp.shader_mat
	pp.mesh = m
	pp.shape = CircleShape2D.new()
	pp.shape.radius = 4.0 * pp.scale
	pp.psqp = PhysicsShapeQueryParameters2D.new()
	pp.psqp.shape = pp.shape
	pp.psqp.collision_mask = 0b0
	
	pp.mod_stack = []
	pp.mod_data = []
	
	return pp


func create_projectile() -> Projectile:
	var proj := Projectile.create()
	proj.proc = self
	
	proj.health = health
	proj.damage = damage
	proj.depth = 0.0
	proj.mesh = mesh
	proj.scale *= scale
	
	Global.Game.render.add_child(proj)
	count += 1
	
	return proj
func destroy_projectile(proj: Projectile) -> void:
	var p := proj.get_parent(); if p: p.remove_child(proj)
	proj.queue_free()
	count -= 1


func process(proj: Projectile, delta: float) -> void:
	if !update(proj, delta): return destroy_projectile(proj)
	
	proj.global_position = Entity.up_dim(proj.trans.origin)
	proj.rotation.y = -proj.vel.angle()

func update(proj: Projectile, delta: float) -> bool:
	var dss: PhysicsDirectSpaceState2D = Global.Game.world_2d.get_world_2d().direct_space_state
	var rem := 1.0
	var i := 0
	psqp.collision_mask = proj.team | (0b0001 << 8)
	
	while rem > 0.0 && proj.health > 0.0 && i < 5: ##TODO do-while
		i += 1
		psqp.transform = proj.trans
		psqp.motion = proj.vel * rem * delta
		var dist := dss.cast_motion(psqp)[1] * rem
		
		proj.trans.origin += proj.vel * dist * delta
		process_modifier(proj, Vector2i.ZERO, delta * dist)
		proj.health -= delta * dist
		rem -= dist
		psqp.transform = proj.trans
		shape.radius += 0.02
		var hits := dss.intersect_shape(psqp)
		shape.radius -= 0.02
		for hit in hits:
			var colc := hit[&"collider"] as PhysicsBody2D
			if colc is Entity: process_collision(proj, colc as Entity)
			if colc is StaticBody2D: proj.health = 0.0
	
	return proj.health > 0.0


func process_collision(proj: Projectile, ent: Entity) -> void:
	if ent.team & proj.team: return
	
	ent.proc.take_proj_damage(ent, proj)
	deal_proj_damage(proj, ent)
	ent.proc.deal_proj_damage(ent, proj)

func deal_proj_damage(proj: Projectile, ent: Entity) -> void:
	proj.health = 0.0



#region MODIFIERS

enum {MOD_DECELERATE, MOD_ACCELERATE, MOD_TIMESCALE, MOD_SIN, MOD_HOME}
var mod_stack: PackedInt32Array
var mod_data: PackedFloat32Array

func add_modifier(type: int, data: Array[float]) -> void:
	mod_stack.append(type)
	mod_data.append_array(data)

func process_modifier(proj: Projectile, i: Vector2i, delta: float) -> void:
	if i.x >= mod_stack.size(): return
	match mod_stack[i.x]:
		MOD_DECELERATE: # [ strength ]
			var x := proj.health / health
			var s_a := x * x
			x = (proj.health - delta * mod_data[i.y]) / health
			var s_b := x * x
			proj.vel *= s_b / s_a
			process_modifier(proj, i+Vector2i(1, 1), delta)
		MOD_ACCELERATE: # [ strength ]
			var x := proj.health / health
			var s_a := x * x
			x = (proj.health - delta * mod_data[i.y]) / health
			var s_b := x * x
			proj.vel *= s_a / s_b
			process_modifier(proj, i+Vector2i(1, 1), delta)
		MOD_TIMESCALE: # [ strength ]
			process_modifier(proj, i+Vector2i(1, 1), delta * mod_data[i.y])
		MOD_SIN: # [ sin-rad/sec? ]
			var s_a := sin((proj.health - health) * mod_data[i.y])
			var s_b := sin((proj.health - health - delta) * mod_data[i.y])
			#proj.basis = proj.basis.rotated(proj.basis.y, s_b - s_a)
			proj.vel = proj.vel.rotated(s_b - s_a)
			process_modifier(proj, i+Vector2i(1, 1), delta)
		MOD_HOME: # [ strength ]
			if !proj.ownr || !proj.ownr.target: return process_modifier(proj, i+Vector2i(1, 1), delta)
			var targ := proj.ownr.target.position - proj.trans.origin
			var ang := targ.angle_to(proj.vel)
			proj.vel = proj.vel.rotated(minf(absf(ang), delta * mod_data[i.y]) * -signf(ang))
			process_modifier(proj, i+Vector2i(1, 1), delta)

#endregion
