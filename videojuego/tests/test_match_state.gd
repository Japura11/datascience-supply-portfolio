extends "res://tests/test_case.gd"


func test_goals_add_to_score() -> void:
	var m := MatchState.new(60.0)
	m.register_goal(0)
	m.register_goal(1)
	m.register_goal(1)
	assert_eq(m.score[0], 1)
	assert_eq(m.score[1], 2)
	assert_eq(m.winner(), 1)


func test_match_ends_and_ignores_late_goals() -> void:
	var m := MatchState.new(10.0)
	m.tick(10.0)
	assert_true(m.is_over())
	m.register_goal(0)
	assert_eq(m.score[0], 0)
	assert_eq(m.winner(), -1)


func test_clock_text() -> void:
	var m := MatchState.new(125.0)
	assert_eq(m.clock_text(), "2:05")
