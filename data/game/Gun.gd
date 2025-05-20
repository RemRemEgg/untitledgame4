class_name Gun
extends RefCounted

var proc: ProcGun
var fire_timer: float = 0.1
var owner: Entity

func update(delta: float) -> void:
	if !owner: return
	proc.update(self, delta)
