class_name AiController
extends Node
## IA muy simple del prototipo 1. Roles: con balón (avanza/tira/pasa), presionar (el más
## cercano al balón), apoyar (compañero con balón) y cubrir (entre balón y portería propia).

const SHOOT_RANGE := 21.0

var director: MatchDirector
var dino: Dino
var _rng := RandomNumberGenerator.new()
var _target_charge: float = -1.0
var _decision_cooldown: float = 0.0


func setup(p_director: MatchDirector, p_dino: Dino, seed_value: int) -> void:
	director = p_director
	dino = p_dino
	_rng.seed = seed_value
	name = "AI_%s" % dino.name


func _physics_process(delta: float) -> void:
	if dino.is_human and not director.autoplay:
		_target_charge = -1.0
		return
	if not dino.can_act() or director.phase != MatchDirector.Phase.PLAYING:
		dino.move_input = Vector3.ZERO
		dino.wants_sprint = false
		_target_charge = -1.0
		if dino.charge_part != "":
			dino.cancel_charge()
		return
	_decision_cooldown -= delta
	if _target_charge >= 0.0:
		if dino.charge_part == "":
			_target_charge = -1.0
		elif dino.charge_amount >= _target_charge:
			dino.release_kick()
			_target_charge = -1.0
		return
	var ball := director.ball
	if ball.possessor == dino:
		_with_ball()
	elif ball.possessor != null and ball.possessor.team == dino.team:
		_support()
	elif director.closest_to_ball(dino.team) == dino:
		_press()
	else:
		_cover()


func _with_ball() -> void:
	var goal := director.goal_center(1 - dino.team)
	var to_goal := _flat(goal - dino.global_position)
	var avoid := Vector3.ZERO
	for other in director.teammates_of(1 - dino.team):
		if other.is_out():
			continue
		var away := _flat(dino.global_position - other.global_position)
		var dist := away.length()
		if dist < 7.0 and dist > 0.01:
			avoid += away / dist * (7.0 - dist) / 7.0
	var dir := (to_goal.normalized() + avoid * 0.9).normalized()
	_steer_to(dino.global_position + dir * 6.0, 1.0)
	dino.wants_sprint = avoid.length() < 0.2
	if _decision_cooldown > 0.0:
		return
	_decision_cooldown = 0.2
	var facing_goal := dino.facing().dot(to_goal.normalized())
	var clear_shot := to_goal.length() < SHOOT_RANGE and facing_goal > 0.8
	var close_shot := to_goal.length() < SHOOT_RANGE * 0.6 and facing_goal > 0.45
	if clear_shot or close_shot:
		dino.move_input = to_goal.normalized()
		_begin_kick(
			"foot", clampf(0.55 + to_goal.length() / 40.0 + _rng.randf_range(-0.1, 0.1), 0.4, 1.0)
		)
		return
	var mate := director.best_pass_target(dino)
	if mate != null and avoid.length() > 0.45:
		var to_mate := _flat(mate.global_position - dino.global_position)
		if dino.facing().dot(to_mate.normalized()) > 0.55:
			dino.move_input = to_mate.normalized()
			var part := "head" if to_mate.length() > 22.0 else "foot"
			_begin_kick(part, clampf(to_mate.length() / 32.0, 0.15, 0.85))


func _press() -> void:
	var ball := director.ball
	var holder := ball.possessor
	if holder != null and holder.team != dino.team:
		# Cortar el paso: ir al punto por donde va a pasar el balón, no a la espalda del rival.
		var intercept := holder.control_point() + _flat(holder.linear_velocity) * 0.5
		_steer_to(intercept, 0.5)
		var to_holder := _flat(holder.global_position - dino.global_position)
		var close := to_holder.length() < 5.0 + dino.body_size().z * 0.5
		if close and dino.facing().dot(to_holder.normalized()) > 0.85 and _decision_cooldown <= 0.0:
			_decision_cooldown = 0.6
			if dino.dash_ready() and _rng.randf() < 0.5:
				dino.try_dash()
		return
	var goal := director.goal_center(1 - dino.team)
	var ball_pos := ball.global_position
	var goal_dir := _flat(goal - ball_pos).normalized()
	var behind := ball_pos - goal_dir * (dino.body_size().z * 0.5 + 2.0)
	var wrong_side := _flat(dino.global_position - ball_pos).dot(goal_dir) > 0.0
	if wrong_side and _flat(behind - dino.global_position).length() > 2.5:
		_steer_to(behind + Vector3(0, 0, 3.0 * signf(dino.global_position.z - ball_pos.z)), 2.0)
	else:
		_steer_to(ball_pos, 0.8)
	# Golpeo de primera si el balón está a tiro.
	var near_ball := dino.control_point().distance_to(ball_pos) < 2.2
	if near_ball and _decision_cooldown <= 0.0:
		_decision_cooldown = 0.3
		var to_goal := _flat(goal - dino.global_position)
		if to_goal.length() < SHOOT_RANGE + 4.0 and dino.facing().dot(to_goal.normalized()) > 0.7:
			dino.move_input = to_goal.normalized()
			_begin_kick("head" if ball_pos.y > 1.6 else "foot", 0.7 + _rng.randf() * 0.3)


func _support() -> void:
	var ball_pos := director.ball.global_position
	var goal := director.goal_center(1 - dino.team)
	var side := -signf(ball_pos.z) if absf(ball_pos.z) > 1.0 else 1.0
	var target := ball_pos + _flat(goal - ball_pos).normalized() * 10.0 + Vector3(0, 0, side * 8.0)
	_steer_to(director.clamp_to_field(target, 3.0), 3.0)


## Cubrir: si el balón está en campo propio, hacer de portero improvisado entre balón y
## portería (el cuerpo bloquea tiros); si no, escalonarse a media distancia.
func _cover() -> void:
	var own_goal := director.goal_center(dino.team)
	var ball_pos := director.ball.global_position
	var to_ball := _flat(ball_pos - own_goal)
	var target: Vector3
	var save_point: Variant = _predict_shot_crossing(own_goal)
	if save_point != null:
		# ¡Parada! Lanzarse al punto por donde va a cruzar el balón.
		_steer_to(save_point, 0.3)
		dino.wants_sprint = true
		return
	if to_ball.length() < director.half_length():
		target = (
			own_goal
			+ to_ball.normalized() * minf(3.0 + dino.body_size().z * 0.5, to_ball.length() * 0.5)
		)
		target.z = clampf(target.z, -director.goal_half_width(), director.goal_half_width())
	else:
		target = own_goal + to_ball * 0.4
	_steer_to(director.clamp_to_field(target, 1.0), 2.0)
	# Encararse al balón para bloquear con el cuerpo.
	if _flat(target - dino.global_position).length() < 1.0:
		dino.move_input = to_ball.normalized() * 0.1


## Si el balón viene rápido hacia la portería propia, devuelve el punto (a la altura del
## defensor) por donde va a pasar; si no, null.
func _predict_shot_crossing(own_goal: Vector3) -> Variant:
	var ball := director.ball
	var v := _flat(ball.linear_velocity)
	var toward_goal := _flat(own_goal - ball.global_position)
	if v.length() < 8.0 or v.normalized().dot(toward_goal.normalized()) < 0.6:
		return null
	if absf(v.x) < 0.1:
		return null
	var t := (dino.global_position.x - ball.global_position.x) / v.x
	if t < 0.0 or t > 1.5:
		return null
	var z := ball.global_position.z + v.z * t
	return Vector3(
		dino.global_position.x,
		0.0,
		clampf(z, -director.goal_half_width() - 1.0, director.goal_half_width() + 1.0)
	)


func _begin_kick(part: String, charge: float) -> void:
	dino.start_charge(part)
	_target_charge = charge


func _steer_to(target: Vector3, arrive: float) -> void:
	var to := _flat(target - dino.global_position)
	var dist := to.length()
	if dist < 0.5:
		dino.move_input = Vector3.ZERO
		dino.wants_sprint = false
		return
	dino.move_input = to / dist * clampf(dist / maxf(arrive, 0.1), 0.25, 1.0)
	dino.wants_sprint = dist > 14.0


func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)
