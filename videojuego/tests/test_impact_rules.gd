extends "res://tests/test_case.gd"

var tuning: Dictionary = GameData.load_tuning()["impact"]


func _hit(att_mass: float, speed: float, def_mass: float, charging: bool = false) -> Dictionary:
	return ImpactRules.compute(
		{"mass": att_mass, "closing_speed": speed, "attack": 3, "charging": charging},
		{"mass": def_mass, "defense": 3, "max_stamina": 100.0},
		tuning
	)


func test_heavier_attacker_hits_harder() -> void:
	assert_gt(_hit(8.0, 8.0, 3.0)["impact"], _hit(1.0, 8.0, 3.0)["impact"])


func test_faster_attacker_hits_harder() -> void:
	assert_gt(_hit(3.0, 12.0, 3.0)["impact"], _hit(3.0, 4.0, 3.0)["impact"])


func test_walking_contact_does_not_knock_down() -> void:
	assert_false(_hit(3.0, 2.0, 3.0)["knockdown"], "un roce caminando no derriba")


func test_small_cannot_knock_down_giant_at_full_speed() -> void:
	var raptor_vs_trex := ImpactRules.compute(
		{"mass": 1.0, "closing_speed": 13.0, "attack": 3, "charging": false},
		{"mass": 8.0, "defense": 4, "max_stamina": 160.0},
		tuning
	)
	assert_false(raptor_vs_trex["knockdown"], "un raptor no derriba a un T-Rex de un golpe")
	assert_gt(raptor_vs_trex["damage"], 0.0, "pero sí lo desgasta")


func test_charging_multiplies_impact() -> void:
	assert_gt(_hit(3.0, 8.0, 3.0, true)["impact"], _hit(3.0, 8.0, 3.0, false)["impact"] * 1.5)


func test_damage_is_capped_per_hit() -> void:
	var brutal := _hit(8.0, 30.0, 1.0, true)
	assert_almost(brutal["damage"], 40.0, 0.01, "máx. 40 % del aguante por golpe")


func test_receding_attacker_does_no_damage() -> void:
	var result := _hit(8.0, -5.0, 3.0)
	assert_eq(result["damage"], 0.0)
	assert_false(result["knockdown"])
