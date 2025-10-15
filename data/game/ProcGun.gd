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
var front_dist := 18.0

enum {MOD_LINE, MOD_SHOTGUN, MOD_SPREAD, MOD_SURROUND}
var mod_stack: PackedInt32Array
var mod_data: PackedFloat32Array

var proj: ProcProj
var inaccuracy: float = 0.0

static func create() -> ProcGun:
	var gun := ProcGun.new()
	
	gun.mod_stack = []
	gun.mod_data = []
	
	return gun

func add_modifier(type: int, data: Array[float]) -> void:
	mod_stack.append(type)
	mod_data.append_array(data)


func process(gun: Gun, trans: Transform2D, entity: Entity, delta: float) -> int:
	var fire_count := 0
	trans = trans.translated_local(Vector2.RIGHT * front_dist)
	match style:
		STYLE_GUN:
			gun.fire_timer += delta * fire_rate
			while gun.fire_timer >= 1.0:
				fire(gun, trans, entity, (gun.fire_timer - 1.0) / fire_rate)
				fire_count += 1
				gun.fire_timer -= 1.0
		STYLE_REPEATER:
			if gun.fire_timer < 0:
				var inc: float = gun.fire_timer + delta * style_data_f
				var vop: int = absi(int(minf(inc, 0.0)) - int(gun.fire_timer))
				while vop > 0:
					fire(gun, trans, entity, (inc - floorf(inc) + vop - 1) / style_data_f)
					fire_count += 1
					vop -= 1
				gun.fire_timer = minf(inc, 0.0)
			else:
				gun.fire_timer += delta * fire_rate
				if gun.fire_timer >= 1.0: gun.fire_timer = -style_data_i
	return fire_count

func fire(_gun: Gun, trans: Transform2D, entity: Entity, delta: float) -> void:
	process_modifier(trans, Vector2i.ZERO, entity, delta)


func process_modifier(trans: Transform2D, i: Vector2i, ownr: Entity, delta: float) -> void:
	if i.x >= mod_stack.size(): return make_bullets(trans, ownr, delta)
	match mod_stack[i.x]:
		MOD_LINE: # [ count, dist ]
			var o := (mod_data[i.y]-1) / 2.0
			for j in int(mod_data[i.y]):
				process_modifier(trans.translated_local(Vector2.DOWN * (j - o) * mod_data[i.y+1]), i+Vector2i(1, 1), ownr, delta)
		MOD_SHOTGUN: # [ count, spread ]
			for __ in int(mod_data[i.y]):
				process_modifier(trans.rotated_local((randf()-0.5)*mod_data[i.y+1]), i+Vector2i(1, 2), ownr, delta)
		MOD_SPREAD: # [ count, angle ]
			var o := (mod_data[i.y]-1) / 2.0
			for j in int(mod_data[i.y]):
				process_modifier(trans.rotated_local((j - o) * mod_data[i.y+1]), i+Vector2i(1, 1), ownr, delta)
		MOD_SURROUND: # [ count ]
			for s in mod_data[i.y]:
				process_modifier(trans.rotated_local(s*((2*PI)/mod_data[i.y])), i+Vector2i(1, 1), ownr, delta)



func make_bullets(trans: Transform2D, ownr: Entity, delta: float) -> void:
	trans = trans.rotated_local((randf()-0.5) * inaccuracy)
	var pp := proj.create_projectile()
	pp.trans = trans
	trans.origin = Vector2.ZERO
	pp.vel = trans*Vector2.RIGHT
	pp.vel *= proj.speed
	pp.ownr = ownr
	pp.team = ownr.team
	proj.update(pp, delta)
