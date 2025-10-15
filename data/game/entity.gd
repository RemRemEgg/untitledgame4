class_name Entity
extends CharacterBody2D

static func up_dim(v_in: Vector2) -> Vector3: return Vector3(v_in.x, 0, v_in.y) / 12.0
static func down_dim(v_in: Vector3) -> Vector2: return Vector2(v_in.x, v_in.z) * 12.0

static var CENTER: Vector2 = Vector2.ZERO
static var CENTER_AVG: Vector3 = Vector3.ZERO

func rotate_and_tilt(rot: Vector2, tilt: Vector2, delta: float) -> Vector2:
	var agt := global_transform.x.angle_to(rot)
	rotate(signf(agt) * minf(delta*proc.rot_speed, absf(agt)))
	tilt = (tilt*Vector2(1,-1)).rotated(rotation)
	tilt = Vector2(agt -tilt.y, -tilt.x)
	rotlerp = Vector2(tilt.x/(absf(tilt.x)+1.0), tilt.y/(absf(tilt.y)+2.5))
	return tilt
func move_and_bonus(move: Vector2, bonus_move_: float, delta: float) -> void:
	#velocity = velocity.move_toward(Vector2.ZERO, delta * proc.speed * 0.5 * ((velocity.length_squared() + 25**2) / (velocity.length_squared() + 30**2)))
	velocity = velocity.move_toward(Vector2.ZERO, delta * velocity.length() * 1)
	#velocity += move * ( + proc.bonus_speed*bonus_move_) * delta
	velocity += move * proc.speed * (1.0 + proc.bonus_speed*bonus_move_) * delta


var proc: ProcEntity
var target: Entity

var coll: CollisionShape2D
var mesh: MeshInstance3D
var rotlerp: Vector2
var hurt_text: TextPopup
var team: int = 0x0

var atk_data: Array[float]
var curr_atk: ProcEntity.AtkExecutor
var move_dir: Vector2
var update_timer: float

var guns: Array[Gun]

var health: float = 60.0
var hurt_time: float = 0.0


static func create() -> Entity:
	var ent := Global.SCN_ENTITY.instantiate() as Entity
	ent.coll = ent.get_child(0) as CollisionShape2D
	ent.mesh = ent.get_child(1) as MeshInstance3D
	ent.remove_child(ent.mesh)
	return ent
func add_to_world() -> Entity:
	mesh.owner = null ##??TODO
	Global.Game.render.add_child(mesh)
	Global.Game.entities.add_child(self)
	return self


func _process(delta: float) -> void:
	proc.process(self, delta)
	queue_redraw()

func _draw() -> void:
	if !Global.DEBUG: return
	draw_line(Vector2.ZERO, global_transform.basis_xform_inv(velocity*0.2), Color.RED, 2.0)
	draw_line(Vector2.ZERO, global_transform.basis_xform_inv(move_dir*50.0), Color.GREEN, 2.0)

func popup_update(damage: float) -> void:
	if hurt_text && is_instance_valid(hurt_text) && hurt_text.time < 1.0 && hurt_text.global_position.distance_squared_to(global_position) < 256**2:
		damage += int(hurt_text.text)
		hurt_text.queue_free()
	var apos: Vector2 = self.global_position + Vector2(0.0, -8)
	hurt_text = TextPopup.instant(str(int(damage)), Vector2(apos.x, apos.y)) as TextPopup
