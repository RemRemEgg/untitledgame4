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
var fire_rate := 1.0    # -, -,
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

func add_modifier(type: int, data: float = 0.0) -> void:
	mod_stack.append(type)
	mod_data.append(data)



func process(gun: Gun, entity: Entity, delta: float) -> void:
	match style:
		STYLE_GUN:
			gun.fire_timer += delta * fire_rate
			while gun.fire_timer > 1.0:
				fire(gun, entity, (gun.fire_timer - 1.0) / fire_rate)
				gun.fire_timer -= 1.0
		STYLE_REPEATER:
			if gun.fire_timer < 0:
				var inc: float = gun.fire_timer + delta * style_data_f
				var vop: int = absi(int(min(inc, 0.0)) - int(gun.fire_timer))
				while vop > 0:
					fire(gun, entity, (inc - floorf(inc) + vop - 1) / style_data_f)
					vop -= 1
				gun.fire_timer = min(inc, 0.0)
			else:
				gun.fire_timer += delta * fire_rate
				if gun.fire_timer >= 1.0: gun.fire_timer = -style_data_i

func fire(gun: Gun, entity: Entity, delta: float) -> void:
	process_modifier(entity.global_position + Vector2.RIGHT.rotated(entity.rotation) * 22.0, entity.rotation, 0, entity, delta)


func process_modifier(pos: Vector2, dir: float, i: int, ownr: Entity, delta: float) -> void:
	if i >= mod_stack.size(): return make_bullets(pos, dir, ownr, delta)
	match mod_stack[i]:
		MOD_DUAL:
			var perp: Vector2 = Vector2.RIGHT.rotated(dir + PI/2) * mod_data[i]
			process_modifier(pos + perp, dir, i+1, ownr, delta)
			process_modifier(pos - perp, dir, i+1, ownr, delta)
		MOD_SHOTGUN:
			for __ in int(mod_data[i]):
				process_modifier(pos, dir + randf_range(-0.15, 0.15), i+1, ownr, delta)
		MOD_SPREAD:
			var s := -mod_data[i]; while s < mod_data[i]:
				process_modifier(pos, dir + s*0.1, i+1, ownr, delta)
				s += 1.0
		MOD_SURROUND:
			for s in mod_data[i]:
				process_modifier(pos, dir + s*((2*PI)/mod_data[i]), i+1, ownr, delta)


func make_bullets(pos: Vector2, dir: float, ownr: Entity, delta: float) -> void:
	var pp := proj.make_projectile(pos, dir+ randf_range(-inaccuracy, inaccuracy), ownr)
	pp._process(delta)
	return
