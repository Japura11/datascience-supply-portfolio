class_name BroadcastCamera
extends Camera3D
## Cámara del partido: vista de transmisión (por defecto) o detrás del jugador (tecla C).
## Incluye temblor por "trauma" para que los choques se sientan.

enum Mode { BROADCAST, BEHIND }

var mode: Mode = Mode.BROADCAST
var ball: Node3D
var target_dino: Dino
var field_half := Vector2(32.0, 20.0)
var _trauma: float = 0.0
var _focus := Vector3.ZERO
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	fov = 50.0
	far = 700.0
	current = true
	_rng.seed = 99


func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func toggle_mode() -> void:
	mode = Mode.BEHIND if mode == Mode.BROADCAST else Mode.BROADCAST


func mode_name() -> String:
	return "Transmisión" if mode == Mode.BROADCAST else "Detrás del jugador"


func _process(delta: float) -> void:
	if ball == null:
		return
	var desired_pos: Vector3
	var look_target: Vector3
	if mode == Mode.BEHIND and target_dino != null and not target_dino.is_out():
		var f := target_dino.facing()
		var h: float = target_dino.body_size().y
		var base := target_dino.global_position
		desired_pos = base - f * (7.0 + h * 1.6) + Vector3.UP * (3.5 + h * 1.1)
		look_target = base + f * 7.0 + Vector3.UP * h * 0.5
	else:
		var f := ball.global_position
		if target_dino != null and not target_dino.is_out():
			f = f.lerp(target_dino.global_position, 0.25)
		f.x = clampf(f.x, -field_half.x + 9.0, field_half.x - 9.0)
		f.z = clampf(f.z, -field_half.y + 6.0, field_half.y - 6.0)
		f.y = 0.0
		desired_pos = f + Vector3(0.0, 24.0, 29.0)
		look_target = f
	var k := 1.0 - exp(-delta * 4.0)
	global_position = global_position.lerp(desired_pos, k)
	_focus = _focus.lerp(look_target, k)
	look_at(_focus, Vector3.UP)
	var shake := _trauma * _trauma
	h_offset = _rng.randf_range(-1.0, 1.0) * shake * 0.9
	v_offset = _rng.randf_range(-1.0, 1.0) * shake * 0.7
	_trauma = maxf(0.0, _trauma - delta * 1.8)


func snap() -> void:
	_focus = Vector3.ZERO
	global_position = Vector3(0.0, 24.0, 29.0)
