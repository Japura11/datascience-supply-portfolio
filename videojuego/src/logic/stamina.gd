class_name Stamina
extends RefCounted
## Aguante de un dinosaurio: baja con los golpes y se regenera lento si no recibe daño.

var max_value: float
var current: float
var regen_delay_s: float
var regen_fraction_per_s: float
var injured_threshold: float
var _time_since_hit: float = 0.0


func _init(
	p_max: float,
	p_regen_delay_s: float = 4.0,
	p_regen_fraction_per_s: float = 0.03,
	p_injured_threshold: float = 0.5
) -> void:
	max_value = maxf(p_max, 1.0)
	current = max_value
	regen_delay_s = p_regen_delay_s
	regen_fraction_per_s = p_regen_fraction_per_s
	injured_threshold = p_injured_threshold


## Aplica daño y devuelve el daño realmente aplicado.
func apply_damage(amount: float) -> float:
	var applied: float = clampf(amount, 0.0, current)
	current -= applied
	_time_since_hit = 0.0
	return applied


func tick(delta: float) -> void:
	_time_since_hit += delta
	if is_depleted() or current >= max_value:
		return
	# Solo cuenta el tiempo transcurrido después de la espera, no el de la espera.
	var regen_time: float = minf(delta, _time_since_hit - regen_delay_s)
	if regen_time > 0.0:
		current = minf(max_value, current + max_value * regen_fraction_per_s * regen_time)


func fraction() -> float:
	return current / max_value


func is_injured() -> bool:
	return current < max_value * injured_threshold


func is_depleted() -> bool:
	return current <= 0.0


func refill() -> void:
	current = max_value
	_time_since_hit = 0.0
