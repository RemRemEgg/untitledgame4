class_name Projectile
extends MeshInstance3D

#var next: Projectile # ll

var proc: ProcProj
var ownr: Entity

#var mesh: MeshInstance3D

var team: int
var vel: Vector2
var trans: Transform2D

var depth: float = 0.0
var damage: float = 4.0
var health: float = 20.0


static func create() -> Projectile:
	var p := new()
	return p

func _process(delta: float) -> void:
	proc.process(self, delta)
