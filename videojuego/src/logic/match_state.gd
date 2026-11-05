class_name MatchState
extends RefCounted
## Estado puro del partido: marcador y reloj.

var duration_s: float
var time_left_s: float
var score: Array[int] = [0, 0]


func _init(p_duration_s: float) -> void:
	duration_s = p_duration_s
	time_left_s = p_duration_s


func tick(delta: float) -> void:
	if not is_over():
		time_left_s = maxf(0.0, time_left_s - delta)


func register_goal(scoring_team: int) -> void:
	if is_over() or scoring_team < 0 or scoring_team > 1:
		return
	score[scoring_team] += 1


func is_over() -> bool:
	return time_left_s <= 0.0


## -1 = empate.
func winner() -> int:
	if score[0] == score[1]:
		return -1
	return 0 if score[0] > score[1] else 1


func clock_text() -> String:
	var total: int = int(ceil(time_left_s))
	return "%d:%02d" % [total / 60, total % 60]
