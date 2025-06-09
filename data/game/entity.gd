class_name Entity
extends CharacterBody2D

static func up_dim(v_in: Vector2) -> Vector3: return Vector3(v_in.x, 0, v_in.y) / 12.0
static func down_dim(v_in: Vector3) -> Vector2: return Vector2(v_in.x, v_in.z) * 12.0

static var DAMAGE_DATA: Array[float] = [0.0]
static var CENTER: Vector2 = Vector2.ZERO
static var CENTER_AVG: Vector3 = Vector3.ZERO



func rotate_and_tilt(rot: Vector2, tilt: Vector2, delta: float) -> Vector2:
	var agt := global_transform.x.angle_to(rot)
	rotate(signf(agt) * minf(delta*proc.rot_speed, absf(agt)))
	tilt = (tilt*Vector2(1,-1)).rotated(rotation)
	tilt = Vector2(agt -tilt.y, -tilt.x)
	rotlerp = Vector2(tilt.x/(absf(tilt.x)+1.0), tilt.y/(absf(tilt.y)+1.5))
	return tilt
func move_and_bonus(move: Vector2, bonus_move_: float, delta: float) -> void:
	velocity *= 1.0 - delta
	velocity += move * (proc.speed + proc.bonus_speed*bonus_move_) * delta


var proc: ProcEntity
var target: Entity

var mesh: MeshInstance3D
var rotlerp: Vector2
var hurt_text: TextPopup
var team: int = 0x0
var state: int = 0

var guns: Array[Gun]

var health: float = 20.0
var hurt_time: float = 0.0

func _ready() -> void:
	mesh = $mesh as MeshInstance3D
	mesh.material_override = proc.shader_mat
	($hurtbox as Area2D).body_entered.connect(_hurtbox_hit)
	remove_child(mesh)
	Global.Game.render.add_child(mesh)
	state = 1

func _process(delta: float) -> void:
	if state != 1: return
	proc.process(self, delta)
	
	mesh.global_position = up_dim(global_position)
	mesh.rotation = Vector3(lerpf(mesh.rotation.x, rotlerp.x, delta*3), -rotation, lerpf(mesh.rotation.z, rotlerp.y, delta*5))
	
	hurt_time -= delta
	if hurt_time < 0: mesh.set_instance_shader_parameter("hurt", false)



func _hurtbox_hit(body: Node2D) -> void:
	if body is Projectile:
		var proj := body as Projectile
		proj._process_collision(self)

func _process_damage() -> void:
	health -= DAMAGE_DATA[0]
	
	if hurt_text && is_instance_valid(hurt_text) && hurt_text.time < 0.25 && (hurt_text.position - global_position).length_squared() < 100025.0:
		DAMAGE_DATA[0] += float(hurt_text.text)
		hurt_text.queue_free()
	hurt_text = TextPopup.instant(str(DAMAGE_DATA[0]), global_position)
	hurt_time = 0.07
	mesh.set_instance_shader_parameter("hurt", true)
	
	if health <= 0.0: kill()

func kill() -> void:
	if state == 2: return
	state = 2
	mesh.get_parent().remove_child(mesh)
	mesh.queue_free()
	queue_free()
