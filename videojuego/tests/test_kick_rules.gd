extends "res://tests/test_case.gd"

var parts: Dictionary = GameData.load_tuning()["kick"]["parts"]


func test_more_charge_more_speed() -> void:
	var weak := KickRules.compute("foot", 0.1, 3, parts)
	var strong := KickRules.compute("foot", 1.0, 3, parts)
	assert_gt(strong["speed"], weak["speed"])


func test_charge_is_clamped() -> void:
	var over := KickRules.compute("foot", 5.0, 3, parts)
	var full := KickRules.compute("foot", 1.0, 3, parts)
	assert_almost(over["speed"], full["speed"])


func test_head_lifts_more_than_foot() -> void:
	var head := KickRules.compute("head", 0.5, 3, parts)
	var foot := KickRules.compute("foot", 0.5, 3, parts)
	assert_gt(head["lift"], foot["lift"])


func test_tail_curves_most() -> void:
	var tail := KickRules.compute("tail", 0.5, 3, parts)
	assert_gt(tail["curve"], KickRules.compute("foot", 0.5, 3, parts)["curve"])
	assert_gt(tail["curve"], KickRules.compute("head", 0.5, 3, parts)["curve"])


func test_finishing_stat_increases_speed() -> void:
	assert_gt(
		KickRules.compute("foot", 0.5, 5, parts)["speed"],
		KickRules.compute("foot", 0.5, 1, parts)["speed"]
	)


func test_low_aim_freedom_keeps_facing() -> void:
	var facing := Vector3.FORWARD
	var aim := KickRules.aim_direction(facing, Vector3.RIGHT, 0.0)
	assert_almost(aim.dot(facing), 1.0, 0.001, "un T-Rex no apunta de lado")


func test_high_aim_freedom_follows_input() -> void:
	var aim := KickRules.aim_direction(Vector3.FORWARD, Vector3.RIGHT, 1.0)
	assert_almost(aim.dot(Vector3.RIGHT), 1.0, 0.001)


func test_no_input_aims_forward() -> void:
	var aim := KickRules.aim_direction(Vector3.FORWARD, Vector3.ZERO, 0.8)
	assert_almost(aim.dot(Vector3.FORWARD), 1.0)


func test_right_input_curves_ball_right() -> void:
	var facing := Vector3.FORWARD
	var spin := KickRules.curve_spin(facing, Vector3.RIGHT, 1.0)
	var accel := KickRules.magnus_accel(facing * 20.0, spin, 0.15)
	assert_gt(accel.dot(Vector3.RIGHT), 0.0, "A/D a la derecha = curva a la derecha")


func test_left_input_curves_ball_left() -> void:
	var spin := KickRules.curve_spin(Vector3.FORWARD, Vector3.LEFT, 1.0)
	var accel := KickRules.magnus_accel(Vector3.FORWARD * 20.0, spin, 0.15)
	assert_gt(accel.dot(Vector3.LEFT), 0.0)


func test_launch_velocity_has_lift() -> void:
	var vel := KickRules.launch_velocity(Vector3.FORWARD, {"speed": 10.0, "lift": 0.5})
	assert_almost(vel.y, 5.0)
	assert_almost(vel.dot(Vector3.FORWARD), 10.0)


func test_full_power_is_less_accurate() -> void:
	var cfg: Dictionary = GameData.load_tuning()["kick"]
	var soft := KickRules.apply_aim_error(Vector3.FORWARD, 0.0, 3, 1.0, cfg)
	var hard := KickRules.apply_aim_error(Vector3.FORWARD, 1.0, 3, 1.0, cfg)
	assert_lt(hard.dot(Vector3.FORWARD), soft.dot(Vector3.FORWARD))


func test_better_finisher_is_more_accurate() -> void:
	var cfg: Dictionary = GameData.load_tuning()["kick"]
	var good := KickRules.apply_aim_error(Vector3.FORWARD, 1.0, 5, 1.0, cfg)
	var bad := KickRules.apply_aim_error(Vector3.FORWARD, 1.0, 1, 1.0, cfg)
	assert_gt(good.dot(Vector3.FORWARD), bad.dot(Vector3.FORWARD))


func test_zero_noise_keeps_aim() -> void:
	var cfg: Dictionary = GameData.load_tuning()["kick"]
	var aim := KickRules.apply_aim_error(Vector3.FORWARD, 1.0, 1, 0.0, cfg)
	assert_almost(aim.dot(Vector3.FORWARD), 1.0)
