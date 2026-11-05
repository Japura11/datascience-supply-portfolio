class_name RefereePterosaur
extends Node3D
## Árbitro pterosaurio: sobrevuela el campo siguiendo el balón (en P1 solo pita saques y goles;
## las faltas llegan en un prototipo posterior, ver docs/design/reglas.md).

var follow_target: Node3D
var _angle: float = 0.0
var _time: float = 0.0
var _wings: Array[Node3D] = []
var _head: Node3D
var _center := Vector3.ZERO


func _ready() -> void:
	var skin := _material(Color(0.78, 0.55, 0.35))
	var membrane := _material(Color(0.62, 0.38, 0.28))
	_box(self, Vector3(0.7, 0.6, 1.8), Vector3.ZERO, skin)
	# Camiseta de árbitro a rayas.
	for i in 3:
		var stripe_color := Color(0.1, 0.1, 0.1) if i % 2 == 0 else Color(0.95, 0.95, 0.95)
		_box(
			self, Vector3(0.74, 0.64, 0.22), Vector3(0, 0, -0.4 + 0.25 * i), _material(stripe_color)
		)
	_head = Node3D.new()
	_head.position = Vector3(0, 0.25, -1.0)
	add_child(_head)
	_box(_head, Vector3(0.45, 0.4, 0.6), Vector3(0, 0, -0.2), skin)
	_box(_head, Vector3(0.18, 0.15, 1.1), Vector3(0, -0.05, -0.9), _material(Color(0.9, 0.8, 0.45)))
	var crest := _box(
		_head, Vector3(0.1, 0.5, 1.0), Vector3(0, 0.35, 0.3), _material(Color(0.85, 0.3, 0.2))
	)
	crest.rotation.x = 0.5
	for side: float in [-1.0, 1.0]:
		var wing := Node3D.new()
		wing.position = Vector3(side * 0.35, 0.1, -0.2)
		add_child(wing)
		_box(wing, Vector3(3.2, 0.06, 1.3), Vector3(side * 1.6, 0, 0.2), membrane)
		_wings.append(wing)


func whistle() -> void:
	var tween := create_tween()
	tween.tween_property(_head, "rotation:x", 0.5, 0.1)
	tween.tween_property(_head, "rotation:x", 0.0, 0.25)


func _process(delta: float) -> void:
	_time += delta
	_angle += delta * 0.35
	if follow_target:
		var target := follow_target.global_position
		_center = _center.lerp(Vector3(target.x * 0.6, 0, target.z * 0.4), 1.0 - exp(-delta * 0.8))
	var radius := 16.0
	var pos := (
		_center + Vector3(cos(_angle) * radius, 15.0 + sin(_time * 0.7) * 1.5, sin(_angle) * radius)
	)
	var tangent := Vector3(-sin(_angle), 0, cos(_angle))
	global_position = pos
	look_at(pos + tangent, Vector3.UP)
	rotation.z = -0.25
	for i in _wings.size():
		var side := -1.0 if i == 0 else 1.0
		_wings[i].rotation.z = side * sin(_time * 5.0) * 0.5


func _box(parent: Node3D, box_size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh.material = material
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
	return instance


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material
