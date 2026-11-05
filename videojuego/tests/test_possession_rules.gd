extends "res://tests/test_case.gd"

var cfg: Dictionary = GameData.load_tuning()["possession"]


func test_controls_slow_ball_nearby() -> void:
	assert_true(PossessionRules.can_control(0.5, 3.0, 0.6, 3, cfg))


func test_cannot_control_far_ball() -> void:
	assert_false(PossessionRules.can_control(3.0, 1.0, 0.6, 3, cfg))


func test_cannot_control_high_ball() -> void:
	assert_false(PossessionRules.can_control(0.5, 1.0, 3.0, 3, cfg))


func test_good_control_tames_faster_balls() -> void:
	var speed := 11.0
	assert_false(PossessionRules.can_control(0.5, speed, 0.6, 1, cfg), "Manejo 1 no la doma")
	assert_true(PossessionRules.can_control(0.5, speed, 0.6, 5, cfg), "Manejo 5 sí")


func test_good_thief_steals_faster() -> void:
	assert_gt(PossessionRules.steal_rate(5, 1, cfg), PossessionRules.steal_rate(1, 5, cfg))
