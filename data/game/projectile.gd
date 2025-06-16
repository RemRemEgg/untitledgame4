class_name Projectile
extends Node2D

var proc: ProcProj
var ownr: Entity

var mesh: MeshInstance3D

var can_hurt: int

var depth: float = 0.0
var speed: float = 1000.0
var damage: float = 4.0
var health: float = 20.0


func _ready() -> void:
	mesh = $mesh as Node3D
	remove_child(mesh)
	Global.Game.render.add_child(mesh)
	mesh.global_position = Entity.up_dim(global_position)
	mesh.scale *= scale.x

func _process(delta: float) -> void:
	proc.process(self, delta)
