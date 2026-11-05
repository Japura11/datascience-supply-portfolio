class_name StadiumBuilder
extends RefCounted
## Construye por código el entorno del prototipo: cielo de tarde, campo con líneas,
## paredes, porterías, gradas de piedra con público y paisaje (árboles, montañas, volcán).

const PITCH_SHADER := """
shader_type spatial;
uniform vec2 half_size = vec2(32.0, 20.0);
uniform float goal_half_width = 4.5;
uniform vec3 grass_a : source_color = vec3(0.33, 0.58, 0.24);
uniform vec3 grass_b : source_color = vec3(0.29, 0.52, 0.21);
varying vec3 world_pos;
void vertex() { world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float line(float d, float w) { return 1.0 - smoothstep(w * 0.5, w * 0.5 + 0.06, abs(d)); }
void fragment() {
    vec2 p = world_pos.xz;
    vec3 col = mix(grass_a, grass_b, step(0.5, fract(p.x / 8.0)));
    float w = 0.25;
    float l = line(abs(p.x) - half_size.x, w) * step(abs(p.y), half_size.y);
    l = max(l, line(abs(p.y) - half_size.y, w) * step(abs(p.x), half_size.x));
    l = max(l, line(p.x, w) * step(abs(p.y), half_size.y));
    l = max(l, line(length(p) - 6.0, w));
    float bx = half_size.x - 9.0;
    float bz = goal_half_width + 5.0;
    l = max(l, line(abs(p.x) - bx, w) * step(abs(p.y), bz));
    l = max(l, line(abs(p.y) - bz, w) * step(bx, abs(p.x)) * step(abs(p.x), half_size.x));
    ALBEDO = mix(col, vec3(0.95), l);
    ROUGHNESS = 0.95;
}
"""


static func build_environment(parent: Node3D) -> void:
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.32, 0.5, 0.78)
	sky_material.sky_horizon_color = Color(0.95, 0.72, 0.5)
	sky_material.ground_horizon_color = Color(0.6, 0.5, 0.38)
	sky_material.ground_bottom_color = Color(0.2, 0.25, 0.15)
	var sky := Sky.new()
	sky.sky_material = sky_material
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.fog_enabled = true
	env.fog_light_color = Color(0.9, 0.75, 0.6)
	env.fog_density = 0.0015
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	parent.add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color(1.0, 0.88, 0.72)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 140.0
	sun.rotation_degrees = Vector3(-38.0, 35.0, 0.0)
	parent.add_child(sun)


## Devuelve {"goal_areas": [área portería equipo 0 (-X), área portería equipo 1 (+X)]}.
static func build_field(parent: Node3D, cfg: Dictionary, ball_radius: float) -> Dictionary:
	var hl: float = cfg["half_length"]
	var hw: float = cfg["half_width"]
	var goal_hw: float = float(cfg["goal_width"]) * 0.5
	var goal_h: float = cfg["goal_height"]
	var depth: float = cfg["goal_depth"]
	var wall_h: float = cfg["wall_height"]
	# Suelo infinito para la física + mallas visuales.
	var ground := StaticBody3D.new()
	var ground_shape := CollisionShape3D.new()
	ground_shape.shape = WorldBoundaryShape3D.new()
	ground.add_child(ground_shape)
	parent.add_child(ground)
	_plane(parent, Vector2(600, 600), Vector3(0, -0.03, 0), _material(Color(0.36, 0.42, 0.22)))
	var pitch_shader := Shader.new()
	pitch_shader.code = PITCH_SHADER
	var pitch_material := ShaderMaterial.new()
	pitch_material.shader = pitch_shader
	pitch_material.set_shader_parameter("half_size", Vector2(hl, hw))
	pitch_material.set_shader_parameter("goal_half_width", goal_hw)
	_plane(parent, Vector2(hl * 2.0 + 10.0, hw * 2.0 + 8.0), Vector3.ZERO, pitch_material)
	# Paredes: valla baja visible + cristal invisible hasta wall_h (el balón casi siempre en juego).
	var board := _material(Color(0.45, 0.3, 0.18))
	var glass := _material(Color(0.8, 0.9, 1.0, 0.08))
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for side: float in [-1.0, 1.0]:
		_wall(
			parent,
			Vector3(hl * 2.0 + 1.0, wall_h, 0.5),
			Vector3(0, wall_h * 0.5, side * (hw + 0.25)),
			board,
			glass
		)
		var seg_len: float = hw - goal_hw
		for z_side: float in [-1.0, 1.0]:
			var pos := Vector3(side * (hl + 0.25), wall_h * 0.5, z_side * (goal_hw + seg_len * 0.5))
			_wall(parent, Vector3(0.5, wall_h, seg_len), pos, board, glass)
		var top_pos := Vector3(side * (hl + depth + 0.25), wall_h * 0.5, 0)
		_wall(parent, Vector3(0.5, wall_h, goal_hw * 2.0), top_pos, board, glass)
	var areas: Array[Area3D] = []
	for side: float in [-1.0, 1.0]:
		areas.append(_build_goal(parent, side, hl, goal_hw, goal_h, depth, ball_radius))
	return {"goal_areas": areas}


static func _build_goal(
	parent: Node3D,
	side: float,
	hl: float,
	goal_hw: float,
	goal_h: float,
	depth: float,
	ball_r: float
) -> Area3D:
	var x0 := side * hl
	var white := _material(Color(0.96, 0.96, 0.92))
	var net := _material(Color(1, 1, 1, 0.35))
	net.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	net.cull_mode = BaseMaterial3D.CULL_DISABLED
	for z_side: float in [-1.0, 1.0]:
		_solid(
			parent, Vector3(0.3, goal_h, 0.3), Vector3(x0, goal_h * 0.5, z_side * goal_hw), white
		)
		_solid(
			parent,
			Vector3(depth, goal_h, 0.1),
			Vector3(x0 + side * depth * 0.5, goal_h * 0.5, z_side * goal_hw),
			net
		)
	_solid(parent, Vector3(0.3, 0.3, goal_hw * 2.0 + 0.3), Vector3(x0, goal_h, 0), white)
	_solid(
		parent,
		Vector3(0.1, goal_h, goal_hw * 2.0),
		Vector3(x0 + side * depth, goal_h * 0.5, 0),
		net
	)
	_solid(
		parent, Vector3(depth, 0.1, goal_hw * 2.0), Vector3(x0 + side * depth * 0.5, goal_h, 0), net
	)
	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var inner := depth - ball_r - 0.2
	box.size = Vector3(inner, goal_h - 0.2, goal_hw * 2.0 - 0.2)
	shape.shape = box
	area.add_child(shape)
	area.position = Vector3(x0 + side * (ball_r + 0.1 + inner * 0.5), goal_h * 0.5, 0)
	parent.add_child(area)
	return area


## Gradas de piedra en tres niveles alrededor del campo. Devuelve el público (Crowd).
static func build_stands(parent: Node3D, cfg: Dictionary, rng: RandomNumberGenerator) -> Crowd:
	var hl: float = cfg["half_length"]
	var hw: float = cfg["half_width"]
	var depth: float = cfg["goal_depth"]
	var stone := _material(Color(0.55, 0.5, 0.44))
	var stone_dark := _material(Color(0.45, 0.4, 0.35))
	var seats := PackedVector3Array()
	for tier in 3:
		var h := 1.3 * float(tier + 1)
		var off := 3.0 + 2.6 * float(tier)
		var mat := stone if tier % 2 == 0 else stone_dark
		for side: float in [-1.0, 1.0]:
			var long_len := hl * 2.0 + 12.0 + off * 2.0
			_visual_box(
				parent, Vector3(long_len, h, 2.6), Vector3(0, h * 0.5, side * (hw + off)), mat
			)
			_seat_row(
				seats, Vector3(-long_len * 0.5, h, side * (hw + off)), Vector3.RIGHT, long_len, rng
			)
			var end_len := hw * 2.0 + off * 2.0
			var end_x := side * (hl + depth + off)
			_visual_box(parent, Vector3(2.6, h, end_len), Vector3(end_x, h * 0.5, 0), mat)
			_seat_row(seats, Vector3(end_x, h, -end_len * 0.5), Vector3.BACK, end_len, rng)
	var crowd := Crowd.new()
	parent.add_child(crowd)
	crowd.setup(seats, rng)
	return crowd


static func _seat_row(
	seats: PackedVector3Array,
	start: Vector3,
	dir: Vector3,
	length: float,
	rng: RandomNumberGenerator
) -> void:
	var count := int(length / 0.9)
	for i in count:
		if rng.randf() < 0.15:
			continue
		var jitter := Vector3(rng.randf_range(-0.2, 0.2), 0, rng.randf_range(-0.3, 0.3))
		seats.append(start + dir * (float(i) * 0.9 + 0.45) + jitter)


## Paisaje de fantasía/naturaleza: árboles low-poly, montañas y un volcán humeante.
static func build_scenery(parent: Node3D, rng: RandomNumberGenerator) -> void:
	var trunk := _material(Color(0.4, 0.27, 0.15))
	var greens: Array[StandardMaterial3D] = [
		_material(Color(0.2, 0.45, 0.2)),
		_material(Color(0.28, 0.52, 0.18)),
		_material(Color(0.16, 0.38, 0.22))
	]
	for i in 60:
		var angle := rng.randf() * TAU
		var dist := rng.randf_range(62.0, 150.0)
		var pos := Vector3(cos(angle) * dist * 1.2, 0, sin(angle) * dist)
		var trunk_h := rng.randf_range(3.0, 7.0)
		_cone(parent, pos + Vector3(0, trunk_h * 0.5, 0), 0.5, 0.6, trunk_h, trunk)
		var crown_h := rng.randf_range(5.0, 10.0)
		var crown_r := rng.randf_range(2.5, 4.5)
		_cone(
			parent,
			pos + Vector3(0, trunk_h + crown_h * 0.45, 0),
			0.0,
			crown_r,
			crown_h,
			greens[i % 3]
		)
	var rock := _material(Color(0.42, 0.45, 0.4))
	for i in 9:
		var angle := float(i) / 9.0 * TAU + rng.randf_range(-0.2, 0.2)
		var dist := rng.randf_range(200.0, 260.0)
		var h := rng.randf_range(35.0, 70.0)
		_cone(
			parent,
			Vector3(cos(angle) * dist, h * 0.5, sin(angle) * dist),
			4.0,
			rng.randf_range(35.0, 55.0),
			h,
			rock
		)
	var volcano_pos := Vector3(-120.0, 0.0, -230.0)
	_cone(
		parent, volcano_pos + Vector3(0, 40, 0), 12.0, 60.0, 80.0, _material(Color(0.3, 0.26, 0.24))
	)
	var lava := _material(Color(1.0, 0.45, 0.1))
	lava.emission_enabled = true
	lava.emission = Color(1.0, 0.4, 0.05)
	lava.emission_energy_multiplier = 3.0
	_cone(parent, volcano_pos + Vector3(0, 80.2, 0), 10.0, 11.0, 0.6, lava)
	var smoke := CPUParticles3D.new()
	smoke.amount = 40
	smoke.lifetime = 12.0
	smoke.preprocess = 12.0
	smoke.direction = Vector3(0.3, 1, 0)
	smoke.spread = 15.0
	smoke.gravity = Vector3(0.4, 0.6, 0)
	smoke.initial_velocity_min = 2.0
	smoke.initial_velocity_max = 4.0
	smoke.scale_amount_min = 6.0
	smoke.scale_amount_max = 12.0
	var puff := SphereMesh.new()
	puff.radius = 1.0
	puff.height = 2.0
	puff.radial_segments = 8
	puff.rings = 4
	var smoke_mat := _material(Color(0.35, 0.33, 0.32, 0.55))
	smoke_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff.material = smoke_mat
	smoke.mesh = puff
	smoke.position = volcano_pos + Vector3(0, 82, 0)
	parent.add_child(smoke)


# --- Utilidades ----------------------------------------------------------------------------


static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material


static func _plane(parent: Node3D, plane_size: Vector2, pos: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = plane_size
	mesh.material = material
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)


static func _visual_box(
	parent: Node3D, box_size: Vector3, pos: Vector3, material: Material
) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh.material = material
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)


static func _solid(parent: Node3D, box_size: Vector3, pos: Vector3, material: Material) -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = box_size
	shape.shape = box
	body.add_child(shape)
	body.position = pos
	parent.add_child(body)
	_visual_box(body, box_size, Vector3.ZERO, material)


## Pared: colisión de altura completa, valla visible de 1 m y cristal casi transparente.
static func _wall(
	parent: Node3D, box_size: Vector3, pos: Vector3, board: Material, glass: Material
) -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = box_size
	shape.shape = box
	body.add_child(shape)
	body.position = pos
	parent.add_child(body)
	var board_h := 1.0
	_visual_box(
		body,
		Vector3(box_size.x, board_h, box_size.z),
		Vector3(0, -box_size.y * 0.5 + board_h * 0.5, 0),
		board
	)
	_visual_box(body, box_size, Vector3.ZERO, glass)


static func _cone(
	parent: Node3D, pos: Vector3, top: float, bottom: float, height: float, material: Material
) -> void:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = 7
	mesh.rings = 1
	mesh.material = material
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
