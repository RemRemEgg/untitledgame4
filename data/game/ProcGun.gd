class_name ProcGun
extends RefCounted

## styles
# gun
# repeator (shells, sustain, gatling)
# chargeup?
# 
## modifiers
# gun (default)
# dual (default)
# shotgun (default)
# set spread (default)
# surround (default)
# lazer (special)
# sniper (special)
# 

enum {STYLE_GUN, STYLE_REPEATER}
var style: int
var fire_rate := 1.0
var style_data_i := 0   # -, repeat count
var style_data_f := 0.0 # -, repeat delay

enum {MOD_DUAL, MOD_SHOTGUN, MOD_SPREAD, MOD_SURROUND}
var mod_stack: PackedInt32Array
var mod_data: PackedFloat32Array

var proj: ProcProj
var inaccuracy: float = 0.0

static func make() -> ProcGun:
	var gun := ProcGun.new()
	
	gun.mod_stack = []
	gun.mod_data = []
	
	return gun

func make_gun() -> Gun:
	var gun := Gun.new()
	gun.proc = self
	return gun

func add_modifier(type: int, data: float = 0.0) -> void:
	mod_stack.append(type)
	mod_data.append(data)



func process(gun: Gun, delta: float) -> void:
	match style:
		STYLE_GUN:
			gun.fire_timer += delta * fire_rate
			while gun.fire_timer > 1.0:
				fire(gun)
				gun.fire_timer -= 1.0
		STYLE_REPEATER:
			if gun.fire_timer < 0:
				var vop := ceilf(floorf(gun.fire_timer + delta*style_data_f) - gun.fire_timer)
				#ceilf((-5.2) - floorf((-5.2) + 0.3))
				gun.fire_timer += delta * style_data_f
				#vop = gun.fire_timer - vop
				while vop > 0:
					vop -= 1
					fire(gun)
				#if floorf((gun.fire_timer) / style_data_f) != floorf((gun.fire_timer + delta) / style_data_f):
					#fire(gun)
				#gun.fire_timer += delta
			else:
				gun.fire_timer += delta * fire_rate
				if gun.fire_timer > 1.0: gun.fire_timer = -style_data_i

func fire(gun: Gun) -> void:
	var entity := gun.owner
	process_modifier(entity.global_position + Vector2.RIGHT.rotated(entity.rotation) * 22.0, entity.rotation, 0, ~entity.team)


func process_modifier(pos: Vector2, dir: float, i: int, team: int) -> void:
	if i >= mod_stack.size(): return make_bullets(pos, dir, team)
	match mod_stack[i]:
		MOD_DUAL:
			var perp: Vector2 = Vector2.RIGHT.rotated(dir + PI/2) * mod_data[i]
			process_modifier(pos + perp, dir, i+1, team)
			process_modifier(pos - perp, dir, i+1, team)
		MOD_SHOTGUN:
			for __ in int(mod_data[i]):
				process_modifier(pos, dir + randf_range(-0.15, 0.15), i+1, team)
		MOD_SPREAD:
			var s := -mod_data[i]; while s < mod_data[i]:
				process_modifier(pos, dir + s*0.1, i+1, team)
				s += 1.0
		MOD_SURROUND:
			for s in mod_data[i]:
				process_modifier(pos, dir + s*((2*PI)/mod_data[i]), i+1, team)


func make_bullets(pos: Vector2, dir: float, team: int) -> void:
	proj.make_projectile(pos, dir+ randf_range(-inaccuracy, inaccuracy), team)
	return
