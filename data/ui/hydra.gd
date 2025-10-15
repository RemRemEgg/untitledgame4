extends CanvasLayer

const HALF_SIZE := Vector2(212, 212) / 2
@onready var ct_neck: GridContainer = $neck as GridContainer
var ct_heads: Array[Node]
const SELECTION_ORDER = [4,0,5, 3,9,1, 7,2,6]

var root: HydraNeck
var neck: HydraNeck
var state: int = 0
var auto_timer: float = 0.0
var auto_selection: int = 0

func _ready() -> void:
	visible = false
	ct_heads = ct_neck.get_children() as Array[Node]
	var PASS := HydraHead.make("", func()->void:pass)
	
	var heal := HydraHead.make("Heal", func()->void: Global.Game.player.health = 1000000)
	var spawn_enemy := HydraHead.make("Spawn Enemy", func()->void: Global.Game.create_enemy(Global.Game.player.get_global_mouse_position()))
	var teleport := HydraHead.make("Teleport", func()->void: Global.Game.player.position = Global.Game.player.get_global_mouse_position())
	var _TEMP_miniboss := HydraHead.make("Miniboss", func()->void:_TEMP_make_miniboss(Global.Game.player.get_global_mouse_position()))
	
	
	var kill_all := HydraHead.make("Kill All", func()->void: for e in Global.Game.entities.get_children(): if e is Entity: (e as Entity).proc.destroy_entity(e as Entity))
	var boost_neck := HydraNeck.make("Boost", [kill_all])
	
	root = HydraNeck.make("root", [heal, spawn_enemy, teleport, PASS, boost_neck, _TEMP_miniboss])
	
	set_active_neck(root)


func _TEMP_make_miniboss(pos: Vector2) -> void:
	var pe := ProcEntity.create(0, 0)
	
	var iks := randi()
	seed(15973)
	pe.shader_mat = SDFBuilder.new().build_shader_3D(Vector3(1.1, 0.2, 1.5))
	pe.mesh.material = pe.shader_mat
	
	
	seed(15000)
	var proj: ProcProj = ProcProj.create()
	proj.speed = 600.0
	var shotgun := ProcGun.create()
	shotgun.proj = proj
	shotgun.fire_rate = 2.0
	shotgun.front_dist = 110.0
	shotgun.add_modifier(ProcGun.MOD_SHOTGUN, [16.0, 0.35])
	
	seed(25000)
	var sproj: ProcProj = ProcProj.create()
	sproj.speed = 800.0
	sproj.damage = 0.5
	var duals := ProcGun.create()
	duals.proj = sproj
	duals.style = ProcGun.STYLE_REPEATER
	duals.fire_rate = 1.0
	duals.style_data_f = 30
	duals.style_data_i = 30*5
	duals.front_dist = 120.0
	duals.inaccuracy = 0.1
	duals.add_modifier(ProcGun.MOD_LINE, [2, 75])
	
	seed(20000)
	var bproj: ProcProj = ProcProj.create()
	bproj.speed = 50.0
	bproj.damage = 100
	bproj.scale = 7.0
	bproj.shape.radius *= bproj.scale
	bproj.health = 30.0
	bproj.add_modifier(ProcProj.MOD_ACCELERATE, [2.5])
	bproj.add_modifier(ProcProj.MOD_SIN, [2.0])
	var burst := ProcGun.create()
	burst.proj = bproj
	burst.fire_rate = 1.0
	burst.front_dist = 0.0
	burst.add_modifier(ProcGun.MOD_SURROUND, [20])
	burst.add_modifier(ProcGun.MOD_LINE, [4, 32])
	pe.guns.append(burst)
	
	var patt := ProcEntity.AtkPattern.new()
	patt.style = ProcEntity.AtkPattern.STYLE_CYCLE
	
	var exe_shotgun := ProcEntity.AtkExecutor.create()
	exe_shotgun.gun = shotgun
	exe_shotgun.fire_count = 10
	patt.attacks.append(exe_shotgun)
	var exe_duals := ProcEntity.AtkExecutor.create()
	exe_duals.gun = duals
	exe_duals.fire_count = 30*5
	patt.attacks.append(exe_duals)
	var exe_burst := ProcEntity.AtkExecutor.create()
	exe_burst.gun = burst
	exe_burst.fire_count = 1
	exe_burst.cooldown = 4.0
	patt.attacks.append(exe_burst)
	
	pe.atk = patt
	pe.guns = []
	pe.atk.finalize(pe)
	
	
	pe.health = 1800
	pe.scale = 110.0
	(pe.coll as CircleShape2D).radius = pe.scale
	pe.speed = 220
	pe.bonus_speed = 0.75
	pe.rot_speed = 1.5
	pe.sep_bias = 0.05
	pe.sep_dist = 200
	
	#var enemy := Global.SCN_ENTITY.instantiate() as Entity
	#enemy.global_position = pos
	#pe.bind(enemy)
	#Global.Game.entities.add_child(enemy)
	
	var enemy := pe.create_entity()
	enemy.global_position = pos
	enemy.add_to_world()
	seed(iks)
	
	#enemy.health = 1800
	#enemy.scale *= 4.0
	#enemy.mesh.scale *= 4.0






func set_active_neck(hn: HydraNeck) -> void:
	ct_neck.global_position = ct_neck.get_global_mouse_position() - HALF_SIZE
	neck = hn
	for i in ct_heads.size():
		var ct_head := ct_heads[i]
		var j = SELECTION_ORDER[i]
		(ct_head.get_child(0) as Label).text = "" if j >= hn.parts.size() else hn.parts[j].text

func _process(delta: float) -> void: if state == 1: update(delta)

func _input(event: InputEvent) -> void:
	if visible && event.is_action("hydra_select") && event.is_pressed():
		return execute()
	if !event.is_action("hydra"): return
	
	
	if event.is_pressed():
		if state == 0: activate()
	else:
		if state == 1: execute()
		reset()
	

func activate() -> void:
	state = 1
	visible = true
	set_active_neck(root)

func update(delta: float) -> void:
	var vec := ct_neck.get_global_mouse_position() - ct_neck.global_position - HALF_SIZE
	auto_timer += delta
	if vec.length_squared() < 38**2: auto_timer = 0
	
	var i := (clampi(roundi(vec.x/(68./1)), -1, 1)+1) + (clampi(roundi(vec.y/(68./1)), -1, 1)+1)*3
	if i < 0 || i > 8: return
	i = SELECTION_ORDER[i]
	if auto_selection == i:
		if auto_timer > 0.2 && i >= 0 && i < neck.parts.size():
			var selection := neck.parts[i]
			if selection is HydraNeck: set_active_neck(selection as HydraNeck)
	else:
		auto_timer = 0
		auto_selection = i
	
	

func execute() -> void:
	var vec := ct_neck.get_global_mouse_position() - ct_neck.global_position - HALF_SIZE
	if vec.length_squared() < 38**2: return
	
	var i := (clampi(roundi(vec.x/(68./1)), -1, 1)+1) + (clampi(roundi(vec.y/(68./1)), -1, 1)+1)*3
	if i < 0 || i > 8: return
	i = SELECTION_ORDER[i]
	if i >= 0 && i < neck.parts.size():
		var selection := neck.parts[i]
		if selection is HydraHead: (selection as HydraHead).command.call()
		if selection is HydraNeck: set_active_neck(selection as HydraNeck)

func reset() -> void:
	state = 0
	visible = false

class HydraPart: var text

class HydraNeck extends HydraPart:
	var parts: Array[HydraPart]
	
	static func make(text_: String, parts_: Array[HydraPart]) -> HydraNeck:
		var hn := HydraNeck.new()
		hn.text = text_
		hn.parts = parts_
		return hn

class HydraHead extends HydraPart:
	var command: Callable
	
	static func make(text_: String, cmd: Callable) -> HydraHead:
		var hh := HydraHead.new()
		hh.text = text_
		hh.command = cmd
		return hh
