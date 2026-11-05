class_name DinoModel
extends Node3D
## Modelo provisional de "bloques" construido por código según el esqueleto y los rasgos
## de la especie, con animación procedural (patas, cola, cabeza). Se reemplazará por los
## modelos low-poly de Blender en el vertical slice; la interfaz (animate/play_*) se mantiene.

# Desplazamientos animables (los usan los tweens de golpeo/choque).
var leg_kick_offset: float = 0.0
var head_offset: float = 0.0
var tail_offset: float = 0.0
var jaw_offset: float = 0.0

var _legs: Array[Node3D] = []
var _leg_phase_offsets: Array[float] = []
var _tail: Node3D
var _tail_tip: Node3D
var _head: Node3D
var _jaw: Node3D
var _phase: float = 0.0
var _time: float = 0.0
var _size := Vector3.ONE
var _leg_length: float = 1.0
var _materials: Dictionary = {}


func build(species: Dictionary, team_color: Color) -> void:
	var body: Dictionary = species["body"]
	_size = Vector3(float(body["width"]), float(body["height"]), float(body["length"]))
	var features: Array = species.get("features", [])
	var main_color := Color(str(species["color"]))
	var accent := Color(str(species.get("accent", species["color"])))
	if str(species["skeleton"]) == "quadruped":
		_build_quadruped(main_color, accent, team_color, features)
	else:
		_build_biped(main_color, accent, team_color, features)


func animate(delta: float, speed: float, max_speed: float, knocked: bool) -> void:
	_time += delta
	var amp: float = 0.0 if knocked else clampf(speed / maxf(max_speed, 0.1), 0.0, 1.0) * 0.7
	_phase += delta * speed / maxf(_leg_length * 1.8, 0.1) * PI
	for i in _legs.size():
		var swing := sin(_phase + _leg_phase_offsets[i]) * amp
		if i == 0:
			swing += leg_kick_offset
		_legs[i].rotation.x = swing
	position.y = absf(sin(_phase)) * amp * 0.06 * _size.y
	if _tail:
		_tail.rotation.y = sin(_phase * 0.5) * 0.15 * amp + sin(_time * 1.4) * 0.08 + tail_offset
		_tail.rotation.x = -0.05 + sin(_time * 1.1) * 0.03
	if _tail_tip:
		_tail_tip.rotation.y = sin(_phase * 0.5 - 0.8) * 0.25 * amp + sin(_time * 1.4 - 0.6) * 0.12
	if _head:
		_head.rotation.x = sin(_phase * 2.0) * 0.04 * amp + head_offset
	if _jaw:
		_jaw.rotation.x = 0.08 + absf(sin(_time * 0.9)) * 0.06 + jaw_offset


func play_kick(part: String) -> void:
	var tween := create_tween()
	match part:
		"foot":
			tween.tween_property(self, "leg_kick_offset", -1.3, 0.08)
			tween.tween_property(self, "leg_kick_offset", 0.0, 0.2)
		"tail":
			tween.tween_property(self, "tail_offset", 1.5, 0.1)
			tween.tween_property(self, "tail_offset", 0.0, 0.3)
		_:
			tween.tween_property(self, "head_offset", -0.6, 0.08)
			tween.tween_property(self, "head_offset", 0.0, 0.25)


func play_tackle() -> void:
	var tween := create_tween()
	tween.tween_property(self, "head_offset", 0.45, 0.08)
	tween.parallel().tween_property(self, "jaw_offset", 0.5, 0.08)
	tween.tween_interval(0.3)
	tween.tween_property(self, "head_offset", 0.0, 0.2)
	tween.parallel().tween_property(self, "jaw_offset", 0.0, 0.2)


# --- Construcción -------------------------------------------------------------------------


func _build_biped(main: Color, accent: Color, team_color: Color, features: Array) -> void:
	var w := _size.x
	var h := _size.y
	var l := _size.z
	_leg_length = h * 0.5
	var hip_y := _leg_length
	var torso_y := hip_y + h * 0.12
	var torso := _box(self, Vector3(w, h * 0.32, l * 0.42), Vector3(0, torso_y, -l * 0.05), main)
	torso.rotation.x = 0.12
	_box(
		self,
		Vector3(w * 0.85, h * 0.12, l * 0.36),
		Vector3(0, torso_y - h * 0.15, -l * 0.05),
		main.lightened(0.25)
	)
	_box(self, Vector3(w * 1.06, h * 0.33, l * 0.1), Vector3(0, torso_y, -l * 0.02), team_color)
	# Patas traseras (pivote en la cadera).
	for side: float in [-1.0, 1.0]:
		var leg := _pivot(self, Vector3(side * w * 0.32, hip_y, l * 0.02))
		_box(leg, Vector3(w * 0.32, hip_y * 0.6, w * 0.45), Vector3(0, -hip_y * 0.28, 0), main)
		_box(
			leg,
			Vector3(w * 0.2, hip_y * 0.5, w * 0.24),
			Vector3(0, -hip_y * 0.72, w * 0.06),
			main.darkened(0.15)
		)
		_box(
			leg,
			Vector3(w * 0.32, hip_y * 0.08, w * 0.6),
			Vector3(0, -hip_y * 0.96, -w * 0.15),
			accent
		)
		if features.has("sickle_claw"):
			var claw := _box(
				leg,
				Vector3(w * 0.08, hip_y * 0.18, w * 0.18),
				Vector3(0, -hip_y * 0.86, -w * 0.42),
				Color(0.95, 0.92, 0.8)
			)
			claw.rotation.x = -0.6
		_legs.append(leg)
		_leg_phase_offsets.append(0.0 if side < 0.0 else PI)
	# Brazos.
	var arm_scale := 0.45 if features.has("tiny_arms") else 1.0
	for side: float in [-1.0, 1.0]:
		var arm := _box(
			self,
			Vector3(w * 0.12, h * 0.16 * arm_scale, w * 0.12),
			Vector3(side * w * 0.42, torso_y - h * 0.02, -l * 0.22),
			main.darkened(0.1)
		)
		arm.rotation.x = -0.7
	# Cuello y cabeza.
	_box(
		self, Vector3(w * 0.45, h * 0.22, w * 0.5), Vector3(0, torso_y + h * 0.13, -l * 0.25), main
	)
	_head = _pivot(self, Vector3(0, torso_y + h * 0.22, -l * 0.27))
	var big := features.has("big_head")
	var head_size := (
		Vector3(w * 0.85, h * 0.24, l * 0.3) if big else Vector3(w * 0.6, h * 0.16, l * 0.24)
	)
	_box(_head, head_size, Vector3(0, 0, -head_size.z * 0.5), main)
	_jaw = _pivot(_head, Vector3(0, -head_size.y * 0.45, -head_size.z * 0.05))
	_box(
		_jaw,
		Vector3(head_size.x * 0.9, head_size.y * 0.3, head_size.z * 0.9),
		Vector3(0, -head_size.y * 0.12, -head_size.z * 0.45),
		main.lightened(0.2)
	)
	if big:
		for side: float in [-1.0, 1.0]:
			_box(
				_jaw,
				Vector3(head_size.x * 0.05, head_size.y * 0.12, head_size.z * 0.6),
				Vector3(side * head_size.x * 0.4, head_size.y * 0.05, -head_size.z * 0.5),
				Color(0.98, 0.96, 0.88)
			)
	_eyes(_head, head_size)
	if features.has("dome_head"):
		var dome := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = w * 0.42
		sphere.height = w * 0.6
		sphere.radial_segments = 10
		sphere.rings = 5
		sphere.material = _material(accent.lightened(0.35))
		dome.mesh = sphere
		dome.position = Vector3(0, head_size.y * 0.55, -head_size.z * 0.45)
		_head.add_child(dome)
	if features.has("feathers"):
		for i in 4:
			var feather := _box(
				self,
				Vector3(w * 0.08, h * 0.12, l * 0.06),
				Vector3(0, torso_y + h * 0.2, -l * 0.15 + l * 0.08 * i),
				accent
			)
			feather.rotation.x = -0.4
	# Cola en dos segmentos.
	_tail = _pivot(self, Vector3(0, torso_y, l * 0.14))
	_box(_tail, Vector3(w * 0.6, h * 0.2, l * 0.3), Vector3(0, 0, l * 0.15), main)
	_tail_tip = _pivot(_tail, Vector3(0, 0, l * 0.3))
	_box(
		_tail_tip,
		Vector3(w * 0.32, h * 0.12, l * 0.32),
		Vector3(0, -0.02, l * 0.15),
		main.darkened(0.1)
	)


func _build_quadruped(main: Color, accent: Color, team_color: Color, features: Array) -> void:
	var w := _size.x
	var h := _size.y
	var l := _size.z
	_leg_length = h * 0.42
	var torso_y := _leg_length + h * 0.2
	_box(self, Vector3(w, h * 0.42, l * 0.58), Vector3(0, torso_y, 0), main)
	_box(
		self,
		Vector3(w * 0.9, h * 0.12, l * 0.5),
		Vector3(0, torso_y - h * 0.2, 0),
		main.lightened(0.2)
	)
	_box(self, Vector3(w * 1.05, h * 0.43, l * 0.1), Vector3(0, torso_y, 0), team_color)
	var leg_positions := [
		Vector3(-w * 0.35, _leg_length, -l * 0.2),
		Vector3(w * 0.35, _leg_length, l * 0.2),
		Vector3(w * 0.35, _leg_length, -l * 0.2),
		Vector3(-w * 0.35, _leg_length, l * 0.2),
	]
	for i in leg_positions.size():
		var leg := _pivot(self, leg_positions[i])
		_box(
			leg,
			Vector3(w * 0.26, _leg_length, w * 0.3),
			Vector3(0, -_leg_length * 0.5, 0),
			main.darkened(0.12)
		)
		_box(
			leg,
			Vector3(w * 0.3, _leg_length * 0.12, w * 0.36),
			Vector3(0, -_leg_length * 0.95, -w * 0.03),
			accent.darkened(0.3)
		)
		_legs.append(leg)
		_leg_phase_offsets.append(0.0 if i < 2 else PI)
	_head = _pivot(self, Vector3(0, torso_y + h * 0.02, -l * 0.3))
	var head_size := Vector3(w * 0.55, h * 0.3, l * 0.26)
	_box(_head, head_size, Vector3(0, -h * 0.03, -head_size.z * 0.5), main)
	_jaw = _pivot(_head, Vector3(0, -head_size.y * 0.4, -head_size.z * 0.2))
	_box(
		_jaw,
		Vector3(head_size.x * 0.5, head_size.y * 0.3, head_size.z * 0.5),
		Vector3(0, 0, -head_size.z * 0.7),
		accent.darkened(0.45)
	)
	_eyes(_head, head_size)
	if features.has("frill"):
		var frill := _box(
			_head, Vector3(w * 1.35, h * 0.6, 0.14), Vector3(0, h * 0.22, 0.02), accent
		)
		frill.rotation.x = 0.45
		var inner_frill := _box(
			_head,
			Vector3(w * 1.15, h * 0.48, 0.16),
			Vector3(0, h * 0.21, 0.04),
			main.lightened(0.15)
		)
		inner_frill.rotation.x = 0.45
	if features.has("three_horns"):
		for side: float in [-1.0, 1.0]:
			_horn(
				_head,
				Vector3(side * head_size.x * 0.3, head_size.y * 0.35, -head_size.z * 0.35),
				h * 0.42,
				w * 0.07
			)
		_horn(_head, Vector3(0, head_size.y * 0.1, -head_size.z * 0.92), h * 0.16, w * 0.06)
	_tail = _pivot(self, Vector3(0, torso_y + h * 0.05, l * 0.28))
	_box(_tail, Vector3(w * 0.45, h * 0.22, l * 0.24), Vector3(0, -0.05, l * 0.12), main)
	_tail_tip = _pivot(_tail, Vector3(0, -0.05, l * 0.24))
	_box(
		_tail_tip,
		Vector3(w * 0.22, h * 0.12, l * 0.2),
		Vector3(0, -0.08, l * 0.1),
		main.darkened(0.1)
	)


func _eyes(parent: Node3D, head_size: Vector3) -> void:
	for side: float in [-1.0, 1.0]:
		var eye_pos := Vector3(side * head_size.x * 0.5, head_size.y * 0.22, -head_size.z * 0.55)
		_box(
			parent,
			Vector3(0.06, head_size.y * 0.22, head_size.y * 0.22),
			eye_pos,
			Color(0.97, 0.95, 0.85)
		)
		_box(
			parent,
			Vector3(0.08, head_size.y * 0.12, head_size.y * 0.12),
			eye_pos + Vector3(side * 0.01, 0, -0.02),
			Color(0.05, 0.05, 0.05)
		)


func _horn(parent: Node3D, pos: Vector3, length: float, radius: float) -> void:
	var horn := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = radius
	cone.height = length
	cone.radial_segments = 6
	cone.material = _material(Color(0.96, 0.93, 0.82))
	horn.mesh = cone
	horn.position = pos + Vector3(0, length * 0.3, -length * 0.35)
	horn.rotation.x = -1.0
	parent.add_child(horn)


func _pivot(parent: Node3D, pos: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pos
	parent.add_child(pivot)
	return pivot


func _box(parent: Node3D, box_size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh.material = _material(color)
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
	return instance


func _material(color: Color) -> StandardMaterial3D:
	var key := color.to_html()
	if not _materials.has(key):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.85
		_materials[key] = material
	return _materials[key]
