class_name Ball
extends RigidBody3D
## Balón físico: rebota, rueda, curva con efecto (Magnus) y se "pega" suave al poseedor.

signal touched(by_team: int)

const BALL_SHADER := """
shader_type spatial;
uniform vec4 color_a : source_color = vec4(0.93, 0.9, 0.8, 1.0);
uniform vec4 color_b : source_color = vec4(0.42, 0.24, 0.12, 1.0);
varying vec3 obj_pos;
void vertex() { obj_pos = VERTEX; }
void fragment() {
    vec3 p = normalize(obj_pos) * 3.14159 * 2.0;
    float m = step(0.0, sin(p.x) * sin(p.y) * sin(p.z));
    ALBEDO = mix(color_a.rgb, color_b.rgb, m);
    ROUGHNESS = 0.55;
}
"""

var radius: float = 0.6
var possessor: Dino = null
var spin: float = 0.0
var last_touch_team: int = -1
var _curve_k: float = 0.15
var _spin_decay: float = 0.5
var _pending_reset: bool = false
var _reset_position := Vector3.ZERO


func setup(cfg: Dictionary) -> void:
	radius = float(cfg["radius"])
	mass = float(cfg["mass"])
	_curve_k = float(cfg["curve_k"])
	_spin_decay = float(cfg["spin_decay_per_s"])


func _ready() -> void:
	name = "Ball"
	can_sleep = false
	continuous_cd = true
	linear_damp = 0.25
	angular_damp = 0.6
	var material := PhysicsMaterial.new()
	material.bounce = 0.55
	material.friction = 0.5
	physics_material_override = material
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = radius
	shape.shape = sphere
	add_child(shape)
	var mesh_instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 20
	mesh.rings = 10
	var shader := Shader.new()
	shader.code = BALL_SHADER
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	mesh.material = shader_material
	mesh_instance.mesh = mesh
	add_child(mesh_instance)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _pending_reset:
		state.transform = Transform3D(Basis.IDENTITY, _reset_position)
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		_pending_reset = false
		return
	if possessor != null and is_instance_valid(possessor) and possessor.can_act():
		_follow_possessor(state)
		return
	if absf(spin) > 0.01:
		var v := state.linear_velocity
		if Vector3(v.x, 0.0, v.z).length() < 3.0:
			spin = 0.0
		else:
			state.apply_central_force(KickRules.magnus_accel(v, spin, _curve_k) * mass)
			spin = move_toward(spin, 0.0, _spin_decay * state.step)


## Conducción: el balón sigue el punto de control delante del dino (sin levantarlo).
func _follow_possessor(state: PhysicsDirectBodyState3D) -> void:
	var to_target := possessor.control_point() - state.transform.origin
	var desired := possessor.linear_velocity + to_target * 10.0
	var v := state.linear_velocity
	var new_v := v.lerp(desired, 0.3)
	new_v.y = v.y
	state.linear_velocity = new_v
	state.angular_velocity = Vector3.UP.cross(Vector3(new_v.x, 0.0, new_v.z)) / radius
	spin = 0.0


func kick(velocity: Vector3, p_spin: float, team: int) -> void:
	possessor = null
	spin = p_spin
	last_touch_team = team
	linear_velocity = velocity
	angular_velocity = Vector3.UP.cross(velocity) / radius + Vector3.UP * p_spin * 8.0
	touched.emit(team)


func reset_to(position_value: Vector3) -> void:
	possessor = null
	spin = 0.0
	_reset_position = position_value
	_pending_reset = true
