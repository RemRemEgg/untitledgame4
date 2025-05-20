class_name GameRunner
extends Node

@onready var vp: SubViewportContainer = $vp as SubViewportContainer
@onready var sub_vp: SubViewport = vp.get_node("sub_vp") as SubViewport

@onready var world_3d: Node3D = get_node("world_3d") as Node3D
@onready var camera: Camera = world_3d.get_node("camera") as Camera
@onready var static_render: Node3D = world_3d.get_node("static_render") as Node3D
@onready var render: Node3D = world_3d.get_node("render") as Node3D

@onready var debug_camera: Camera2D = sub_vp.get_node("debug_camera") as Camera2D
@onready var world_2d: Node2D = sub_vp.get_node("world_2d") as Node2D
@onready var entities: Node2D = world_2d.get_node("entities") as Node2D
@onready var projectiles: Node2D = world_2d.get_node("projectiles") as Node2D

@onready var world_control: Control = sub_vp.get_node("world_control") as Control
@onready var popups: Control = world_control.get_node("popups") as Control

var player: Player
var proc_entities: Array[ProcEntity] = []
var proc_count := 0

func _enter_tree() -> void:
	Global.Game = self

func _ready() -> void:
	player = Global.SCN_PLAYER.instantiate() as Player
	world_2d.add_child(player)
	
	var size: Vector2i = Vector2i(64, 64)
	var tgen: TerrainGenerator = TerrainGenerator.new()
	tgen.plane(size)
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = int(Time.get_unix_time_from_system())
	for x in range(size.x): for y in range(size.y):
			tgen.verts[tgen.index(x,y)].y += (noise.get_noise_2d(x, y))*16.0
	tgen.build_surface_array().build_mesh().update_normals()
	$world_3d/static_render/ground.mesh = tgen.mesh


var wave_delay: float = 1.0
var wave_total: int
var wave_count: int = 50


func _process(delta: float) -> void:
	for proce in proc_entities: proce.preprocess()
	Entity.CENTER = Vector2(Entity.CENTER_AVG.x, Entity.CENTER_AVG.y) / Entity.CENTER_AVG.z
	if Entity.CENTER_AVG.z == 0: Entity.CENTER = Vector2.ZERO
	Entity.CENTER_AVG = Vector3.ZERO
	
	wave_delay -= delta
	if wave_delay <= 0 && wave_count > 0:
		wave_delay = 15
		wave_total += 4
		wave_count -= 1
	
	while wave_total > 0:
		wave_total -= 1
		spawn_enemy()



func spawn_enemy() -> void:
	if proc_count % int(3**proc_entities.size() + 1) == 0:
		proc_entities.append(ProcEntity.make())
	proc_count += 1
	var pos: Vector2 = player.position
	while pos.distance_squared_to(player.position) < 1200**2: pos = Vector2.LEFT.rotated(randf() * PI * 2) * 2400
	create_enemy(pos)

func create_enemy(pos: Vector2) -> void:
	var enemy := Global.SCN_ENTITY.instantiate() as Entity
	enemy.global_position = pos
	proc_entities[randi_range(0, proc_entities.size()-1)].bind(enemy)
	Global.Game.entities.add_child(enemy)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var eiemb := event as InputEventMouseButton
		match eiemb.button_index:
			1 when eiemb.pressed: spawn_enemy()
			2 when eiemb.pressed: for c in Global.Game.entities.get_children(): c.kill()
			3 when eiemb.pressed: player.global_position = player.get_global_mouse_position()
			4 when eiemb.pressed: Engine.time_scale *= 2
			5 when eiemb.pressed: Engine.time_scale *= 0.5
	if event is InputEventKey:
		var eiek := event as InputEventKey
		match eiek.keycode:
			KEY_F3 when eiek.pressed: toggle_debug()


func toggle_debug() -> void:
	Global.DEBUG = !Global.DEBUG
	
	get_tree().debug_collisions_hint = Global.DEBUG
	
	var old_mode := DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(DisplayServer.window_get_size() + Vector2i(1, 1))
	DisplayServer.window_set_size(DisplayServer.window_get_size() - Vector2i(1, 1))
	DisplayServer.window_set_mode(old_mode)
