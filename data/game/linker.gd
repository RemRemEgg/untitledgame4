class_name Linker
extends Node

var source: Node2D
var target: Node3D

static func create(_source: Node2D, _target: Node3D) -> Linker:
	var link := Linker.new()
	link.source = _source
	link.target = _target
	return link

func _process(x:float) -> void:
	target.global_position.x = source.global_position.x / 12
	target.global_position.z = source.global_position.y / 12
	target.rotation.y = source.rotation
