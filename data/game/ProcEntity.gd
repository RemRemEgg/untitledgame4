class_name ProcEntity
extends RefCounted

var shader_mat: ShaderMaterial
var coll: Shape2D
var mesh: PlaneMesh

var guns: Array[ProcGun] = []
var atk: AtkProcessor
var mem_size: int

var team: int
var health: float = 60.0

var rot_speed: float = 1.2
var speed: float = 350.0
var bonus_speed: float = 0.1
var scale: float = 20.0
var sep_bias: float = 0.0
var sep_dist: float = 0.0

static func create(__: int, ___: int) -> ProcEntity:
	var pe := ProcEntity.new()
	pe.team = 0b0010
	
	var shape := CircleShape2D.new()
	shape.radius = pe.scale
	pe.coll = shape
	
	pe.shader_mat = SDFBuilder.new().build_shader_3D(Vector3(randf(), randf(), randf()).normalized() * 7./5)
	var mesh_ := PlaneMesh.new()
	mesh_.size = Vector2(6.0, 6.0)
	pe.mesh = mesh_
	pe.mesh.material = pe.shader_mat
	
	
	pe.sep_bias = (randf_range(0.0, 2.0)**2) / 4.2 + 0.05
	pe.sep_dist = randf_range(100, 400)
	
	var patt := AtkPattern.new()
	patt.style = AtkPattern.STYLE_CYCLE
	
	var exe_normal := AtkExecutor.create()
	exe_normal.fire_count = 4
	patt.attacks.append(exe_normal)
	var exe_shotgun := AtkExecutor.create()
	exe_shotgun.gun.add_modifier(ProcGun.MOD_SHOTGUN, [4, 0.16])
	patt.attacks.append(exe_shotgun)
	
	
	pe.atk = patt
	pe.guns = []
	pe.atk.finalize(pe)
	
	return pe

func create_entity() -> Entity:
	var ent := Entity.create()
	
	ent.proc = self
	ent.coll.shape = coll
	ent.mesh.mesh = mesh
	ent.mesh.scale *= scale / 20.0
	ent.team = team
	ent.collision_layer |= ~team & 0b1111
	
	ent.atk_data = [] # TODO cache?
	ent.atk_data.resize(mem_size)
	ent.atk_data.fill(0)
	
	ent.health = health
	ent.guns = []
	ent.guns.resize(guns.size())
	for i in guns.size(): ent.guns[i] = Gun.new()
	
	return ent
func destroy_entity(ent: Entity) -> void:
	var p := ent.mesh.get_parent(); if p: p.remove_child(ent.mesh)
	ent.mesh.queue_free()
	ent.queue_free()


func preprocess() -> void:
	pass


func process(ent: Entity, delta: float) -> void:
	if !update(ent, delta): return destroy_entity(ent)
	
	ent.mesh.global_position = Entity.up_dim(ent.global_position)
	ent.mesh.rotation = Vector3(lerpf(ent.mesh.rotation.x, ent.rotlerp.x, delta*3), -ent.rotation, lerpf(ent.mesh.rotation.z, ent.rotlerp.y, delta*5))
	ent.hurt_time -= delta
	if ent.hurt_time < 0: ent.mesh.set_instance_shader_parameter("hurt", false)

func verify_entity(ent: Entity) -> bool: return ent != null && is_instance_valid(ent)

func update(ent: Entity, delta: float) -> bool:
	if !verify_entity(ent): return false
	if !verify_entity(ent.target):
		if !update_target(ent): return ent.health > 0.0
	var targ := ent.target
	
	if !ent.curr_atk: ent.curr_atk = atk.get_attack(ent)
	if ent.curr_atk:
		ent.curr_atk.process(ent, delta)
		if !ent.curr_atk:
			var old_atk := ent.curr_atk
			ent.curr_atk = atk.get_attack(ent)
			if ent.curr_atk != old_atk: ent.guns[ent.curr_atk.gun_index].fire_timer = 0.0
	
	Entity.CENTER_AVG += Vector3(ent.global_position.x, ent.global_position.y, 1)
	
	return ent.health > 0.0

func update_target(ent: Entity) -> bool:
	if !ent is Player:
		ent.target = Global.Game.player as Entity
		return true
	return false

#region damage

func take_proj_damage(ent: Entity, proj: Projectile) -> void:
	ent.health -= proj.damage
	ent.hurt_time = 0.07
	ent.mesh.set_instance_shader_parameter("hurt", true)
	ent.popup_update(proj.damage)

func deal_proj_damage(ent: Entity, proj: Projectile) -> void:
	pass

#endregion

#region attacks

class AtkProcessor:
	var index := 0
	
	func finalize(pe: ProcEntity) -> void:pass
	
	func get_attack(_ent: Entity) -> AtkExecutor:
		return null

class AtkPattern extends AtkProcessor:
	var attacks: Array[AtkProcessor] = []
	var style: int
	enum {STYLE_NONE, STYLE_DIST_2, STYLE_CYCLE, STYLE_HEALTH, STYLE_PLADDER, STYLE_BOUNCE}
	
	func finalize(pe: ProcEntity) -> void:
		index = pe.mem_size
		pe.mem_size += 1
		for atk in attacks:
			atk.finalize(pe)
	
	func get_attack(ent: Entity) -> AtkExecutor:
		match style:
			STYLE_NONE:
				return attacks[0].get_attack(ent)
			STYLE_DIST_2:
				var dist := ent.target.position.distance_to(ent.position)
				if dist <= ent.atk_data[index]:
					return attacks[0].get_attack(ent)
				return attacks[1].get_attack(ent)
			STYLE_CYCLE:
				if ent.atk_data[index] >= attacks.size():
					ent.atk_data[index] = 0
				ent.atk_data[index] += 1
				return attacks[ent.atk_data[index]-1].get_attack(ent)
			STYLE_HEALTH:
				if (ent.health / ent.proc.health) >= ent.atk_data[index]:
					return attacks[0].get_attack(ent)
				return attacks[1].get_attack(ent)
			STYLE_PLADDER:
				var n := attacks.size()
				var i := int(ent.atk_data[index])
				var r := i % n
				i += 1
				if i >= n*n: i = 0
				if (i % n) > (i / n):
					i += n - (r + 1)
				ent.atk_data[index] = i
				return attacks[r].get_attack(ent)
			#STYLE_BOUNCE:
				#ent.atk_data[index]
			_: return null

class AtkExecutor extends AtkProcessor:
	var gun: ProcGun
	var gun_index: int
	var fire_count: int = 1
	var cooldown: float = 1.0
	
	static func create() -> AtkExecutor:
		var ae := AtkExecutor.new()
		
		var gun: ProcGun = ProcGun.create()
		var proj: ProcProj = ProcProj.create()
		proj.speed = 600.0
		gun.proj = proj
		gun.fire_rate = 0.8
		ae.gun = gun
		
		return ae
	
	func finalize(pe: ProcEntity) -> void:
		index = pe.mem_size
		pe.mem_size += 1
		gun_index = pe.guns.size()
		pe.guns.append(gun)
	
	func get_attack(_ent: Entity) -> AtkExecutor:
		return self
	
	func process(ent: Entity, delta: float) -> void:
		var targ := ent.target
		ent.update_timer -= delta
		if ent.update_timer <= 0.0:
			ent.update_timer = 0.25 + randf()*0.25
			var p := (targ.global_position - Entity.CENTER)*0.35 + targ.global_position
			var c := (Entity.CENTER - ent.global_position).normalized()
			var t := (p - ent.global_position)
			ent.move_dir = (t.normalized() - (c * ent.proc.sep_bias)).normalized()
			var dist := t.length()
			ent.move_dir *= (1.0 if dist > ent.proc.sep_dist else -0.5)
			
		var rot := (targ.global_position + targ.velocity * delta - ent.global_position).normalized()
		var tilt: Vector2 = ent.rotate_and_tilt(rot, ent.move_dir, delta)
		ent.move_and_bonus(ent.move_dir, -tilt.y, delta)
		
		ent.move_and_slide()
		
		if ent.atk_data[index] >= 0.0:
			ent.atk_data[index] += gun.process(ent.guns[gun_index], ent.global_transform, ent, delta)
			if ent.atk_data[index] >= fire_count:
				ent.atk_data[index] = -cooldown
		else:
			ent.atk_data[index] += delta
			if ent.atk_data[index] >= 0.0:
				ent.atk_data[index] = 0.0
				ent.curr_atk = null

#endregion
