class_name KickRules
extends RefCounted
## Reglas puras de golpeo según la parte del cuerpo (pata, cola, cabeza),
## puntería según anatomía y efecto (curva por Magnus).

const PARTS: Array[String] = ["foot", "tail", "head"]


## Velocidad, elevación y curva de un golpe. charge en [0, 1], finishing = atributo Remate (1-5).
static func compute(
	part: String, charge: float, finishing: int, parts_cfg: Dictionary
) -> Dictionary:
	var cfg: Dictionary = parts_cfg.get(part, parts_cfg.get("foot", {}))
	var c: float = clampf(charge, 0.0, 1.0)
	var finishing_mult: float = 0.8 + 0.1 * float(finishing)
	var speed: float = lerpf(float(cfg.get("min_speed", 8.0)), float(cfg.get("max_speed", 20.0)), c)
	return {
		"speed": speed * finishing_mult,
		"lift": lerpf(float(cfg.get("lift_min", 0.05)), float(cfg.get("lift_max", 0.15)), c),
		"curve": float(cfg.get("curve", 0.0)),
	}


## Dirección de golpeo: mezcla hacia dónde mira el dino con el input según su libertad
## anatómica de puntería (un T-Rex apunta casi solo hacia delante; un raptor, donde quiere).
static func aim_direction(facing: Vector3, input_dir: Vector3, aim_freedom: float) -> Vector3:
	var f := Vector3(facing.x, 0.0, facing.z).normalized()
	var i := Vector3(input_dir.x, 0.0, input_dir.z)
	if i.length() < 0.1:
		return f
	var mixed: Vector3 = f.lerp(i.normalized(), clampf(aim_freedom, 0.0, 1.0))
	if mixed.length() < 0.01:
		return f
	return mixed.normalized()


## Error de puntería: más potencia = menos precisión; el Remate (1-5) lo reduce.
## noise en [-1, 1] (aleatorio desde fuera, para que la regla sea determinista y testeable).
static func apply_aim_error(
	aim: Vector3, charge: float, finishing: int, noise: float, kick_cfg: Dictionary
) -> Vector3:
	var error_deg: float = lerpf(
		float(kick_cfg.get("aim_error_min_deg", 1.5)),
		float(kick_cfg.get("aim_error_max_deg", 11.0)),
		clampf(charge, 0.0, 1.0)
	)
	error_deg *= 1.25 - 0.1 * float(finishing)
	return aim.rotated(Vector3.UP, deg_to_rad(error_deg * clampf(noise, -1.0, 1.0)))


static func launch_velocity(aim: Vector3, kick: Dictionary) -> Vector3:
	var speed: float = kick["speed"]
	var lift: float = kick["lift"]
	var flat := Vector3(aim.x, 0.0, aim.z).normalized()
	return flat * speed + Vector3.UP * speed * lift


## Efecto: el input lateral (respecto a donde mira el dino) al soltar curva el balón hacia ese lado.
static func curve_spin(facing: Vector3, input_dir: Vector3, curve: float) -> float:
	var right: Vector3 = Vector3(facing.x, 0.0, facing.z).normalized().cross(Vector3.UP)
	var lateral: float = clampf(input_dir.dot(right), -1.0, 1.0)
	return -lateral * curve


## Fuerza lateral por efecto Magnus (aceleración, multiplicar por la masa para fuerza).
static func magnus_accel(velocity: Vector3, spin: float, curve_k: float) -> Vector3:
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	return Vector3.UP.cross(flat) * spin * curve_k
