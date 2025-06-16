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
	var _TEMP_miniboss := HydraHead.make("Miniboss", _TEMP_make_miniboss)
	
	
	var kill_all := HydraHead.make("Kill All", func()->void: for e in Global.Game.entities.get_children(): if e is Entity: (e as Entity).kill())
	var boost_neck := HydraNeck.make("Boost", [kill_all])
	
	root = HydraNeck.make("root", [heal, spawn_enemy, teleport, PASS, boost_neck, _TEMP_miniboss])
	
	set_active_neck(root)


func _TEMP_make_miniboss() -> void:
	var pe := ProcEntity.new()
	
	var iks := randi()
	seed(15973)
	pe.shader_mat = SDFBuilder.new().build_shader_3D(Vector3(1.1, 0.2, 1.5))
	seed(iks)
	
	
	
	var proj: ProcProj = ProcProj.make()
	proj.speed = 600.0
	var main := ProcGun.make()
	main.proj = proj
	main.fire_rate = 2.0
	main.add_modifier(ProcGun.MOD_SPREAD, 3.0)
	pe.guns.append(main)
	
	var sproj: ProcProj = ProcProj.make()
	sproj.speed = 1000.0
	sproj.damage = 0.5
	var sec := ProcGun.make()
	sec.proj = sproj
	sec.style = ProcGun.STYLE_REPEATER
	sec.fire_rate = 1./10
	sec.style_data_f = 30
	sec.style_data_i = 30*5
	sec.add_modifier(ProcGun.MOD_DUAL, 22)
	pe.guns.append(sec)
	
	var bproj: ProcProj = ProcProj.make()
	bproj.speed = 250.0
	bproj.damage = 100
	bproj.scale = 5.0
	bproj.max_health = 12.0
	var burst := ProcGun.make()
	burst.proj = bproj
	burst.fire_rate = 1./15
	burst.add_modifier(ProcGun.MOD_SURROUND, 12)
	burst.add_modifier(ProcGun.MOD_DUAL, 24)
	burst.add_modifier(ProcGun.MOD_DUAL, 12)
	pe.guns.append(burst)
	
	
	pe.speed = 250
	pe.bonus_speed = 0.75
	pe.rot_speed = 1.5
	pe.sep_bias = 0.0
	
	var enemy := Global.SCN_ENTITY.instantiate() as Entity
	enemy.global_position = Global.Game.player.get_global_mouse_position()
	pe.bind(enemy)
	Global.Game.entities.add_child(enemy)
	
	enemy.health = 1800
	enemy.scale *= 4.0
	enemy.mesh.scale *= 4.0






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
	
	var i := (clampi(roundi(vec.x/(68/1)), -1, 1)+1) + (clampi(roundi(vec.y/(68/1)), -1, 1)+1)*3
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
	
	var i := (clampi(roundi(vec.x/(68/1)), -1, 1)+1) + (clampi(roundi(vec.y/(68/1)), -1, 1)+1)*3
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
