extends "res://tests/test_case.gd"


func test_damage_reduces_and_clamps_at_zero() -> void:
	var s := Stamina.new(100.0)
	assert_almost(s.apply_damage(30.0), 30.0)
	assert_almost(s.current, 70.0)
	assert_almost(s.apply_damage(500.0), 70.0)
	assert_true(s.is_depleted())


func test_no_regen_before_delay() -> void:
	var s := Stamina.new(100.0, 4.0, 0.1)
	s.apply_damage(50.0)
	s.tick(3.9)
	assert_almost(s.current, 50.0)


func test_regen_after_delay_and_capped() -> void:
	var s := Stamina.new(100.0, 4.0, 0.1)
	s.apply_damage(50.0)
	s.tick(4.0)
	s.tick(1.0)
	assert_almost(s.current, 60.0)
	for i in 100:
		s.tick(1.0)
	assert_almost(s.current, 100.0)


func test_depleted_does_not_regen() -> void:
	var s := Stamina.new(100.0, 0.0, 1.0)
	s.apply_damage(100.0)
	s.tick(10.0)
	assert_true(s.is_depleted(), "fuera de combate no se cura solo")


func test_injured_threshold() -> void:
	var s := Stamina.new(100.0, 4.0, 0.03, 0.5)
	s.apply_damage(49.0)
	assert_false(s.is_injured())
	s.apply_damage(2.0)
	assert_true(s.is_injured())
