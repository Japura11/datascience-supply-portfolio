class_name Crowd
extends MultiMeshInstance3D
## Público de las gradas: cientos de figuras que botan más cuanto más emoción hay.

const BASE_EXCITEMENT := 0.15
const CROWD_SHADER := """
shader_type spatial;
uniform float excitement = 0.15;
varying vec3 tint;
void vertex() {
    float phase = INSTANCE_CUSTOM.x * 6.2831;
    float rate = 3.0 + INSTANCE_CUSTOM.y * 5.0;
    float bounce = abs(sin(TIME * rate + phase));
    VERTEX.y += bounce * mix(0.04, 0.7, excitement);
    tint = COLOR.rgb;
}
void fragment() { ALBEDO = tint; ROUGHNESS = 0.9; }
"""

var excitement: float = BASE_EXCITEMENT
var _shader_material: ShaderMaterial


func setup(seats: PackedVector3Array, rng: RandomNumberGenerator) -> void:
	var body := CapsuleMesh.new()
	body.radius = 0.28
	body.height = 1.0
	body.radial_segments = 6
	body.rings = 2
	var shader := Shader.new()
	shader.code = CROWD_SHADER
	_shader_material = ShaderMaterial.new()
	_shader_material.shader = shader
	material_override = _shader_material
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = body
	mm.instance_count = seats.size()
	var palette: Array[Color] = [
		Color(0.2, 0.45, 0.95),
		Color(0.95, 0.3, 0.25),
		Color(0.95, 0.85, 0.3),
		Color(0.9, 0.9, 0.9),
		Color(0.35, 0.75, 0.4),
		Color(0.6, 0.4, 0.75),
	]
	for i in seats.size():
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, seats[i] + Vector3.UP * 0.5))
		mm.set_instance_color(i, palette[rng.randi() % palette.size()].darkened(rng.randf() * 0.3))
		mm.set_instance_custom_data(i, Color(rng.randf(), rng.randf(), 0, 0))
	multimesh = mm


func pulse(amount: float) -> void:
	excitement = clampf(excitement + amount, 0.0, 1.0)


func _process(delta: float) -> void:
	excitement = move_toward(excitement, BASE_EXCITEMENT, delta * 0.22)
	if _shader_material:
		_shader_material.set_shader_parameter("excitement", excitement)
