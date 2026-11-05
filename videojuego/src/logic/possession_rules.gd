class_name PossessionRules
extends RefCounted
## Reglas puras de control y robo de balón.


## ¿Puede un dino hacerse con el balón? Depende de la distancia a su punto de control,
## la velocidad relativa del balón y su atributo Manejo.
static func can_control(
	distance: float, relative_speed: float, ball_height: float, control_stat: int, cfg: Dictionary
) -> bool:
	if ball_height > float(cfg.get("max_control_height", 1.6)):
		return false
	if distance > float(cfg.get("control_radius", 1.3)):
		return false
	var max_speed: float = (
		float(cfg.get("base_control_speed", 6.0))
		+ float(cfg.get("control_speed_per_point", 2.0)) * float(control_stat)
	)
	return relative_speed <= max_speed


## Ritmo de robo por segundo (1.0 acumulado = robo). Robo del ladrón contra Manejo del portador.
static func steal_rate(steal_stat: int, holder_control_stat: int, cfg: Dictionary) -> float:
	var total: float = maxf(float(steal_stat + holder_control_stat), 1.0)
	return float(cfg.get("steal_rate_base", 1.2)) * 2.0 * float(steal_stat) / total
