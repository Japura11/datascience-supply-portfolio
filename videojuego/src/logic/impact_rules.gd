class_name ImpactRules
extends RefCounted
## Reglas puras de choque entre dinosaurios. Sin dependencias del motor: testeable.
##
## attacker: {mass, closing_speed, attack, charging}
## defender: {mass, defense, max_stamina}
## Devuelve: {impact, damage, knockdown, knockback_speed}


static func compute(attacker: Dictionary, defender: Dictionary, tuning: Dictionary) -> Dictionary:
	var speed: float = maxf(float(attacker.get("closing_speed", 0.0)), 0.0)
	var attacker_mass: float = float(attacker.get("mass", 1.0))
	var defender_mass: float = maxf(float(defender.get("mass", 1.0)), 0.01)
	# La masa importa, pero con raíz y límites para que un pequeño no sea irrelevante.
	var ratio: float = clampf(sqrt(attacker_mass / defender_mass), 0.3, 3.0)
	var attack_mult: float = 0.6 + 0.2 * float(attacker.get("attack", 1))
	if bool(attacker.get("charging", false)):
		attack_mult *= float(tuning.get("charge_attack_mult", 1.8))
	var defense_mult: float = 1.0 / (0.6 + 0.2 * float(defender.get("defense", 1)))
	var impact: float = speed * ratio * attack_mult * defense_mult
	var max_damage: float = (
		float(defender.get("max_stamina", 100.0))
		* float(tuning.get("max_damage_fraction_per_hit", 0.4))
	)
	var damage: float = minf(impact * float(tuning.get("damage_scale", 2.0)), max_damage)
	if damage < float(tuning.get("min_damage", 1.0)):
		damage = 0.0
	return {
		"impact": impact,
		"damage": damage,
		"knockdown": impact >= float(tuning.get("knockdown_threshold", 9.0)),
		"knockback_speed": impact * float(tuning.get("knockback_scale", 0.5)),
	}
