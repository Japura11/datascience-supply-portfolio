class_name MatchDirector
extends Node3D
## Prototipo 1: construye el mundo y dirige el partido 2 vs 2 (saque → juego → gol → final).
## Gestiona posesión y robo, goles, y la sensación de impacto: hit-stop, temblor, polvo y sonido.

enum Phase { KICKOFF, PLAYING, GOAL, ENDED }

const TEAM_COLORS: Array[Color] = [Color(0.2, 0.5, 1.0), Color(1.0, 0.3, 0.25)]
const TEAM_NAMES: Array[String] = ["AZUL", "ROJO"]
const FORMATION: Array[Vector3] = [Vector3(-9.0, 0.0, -5.0), Vector3(-20.0, 0.0, 7.0)]

## true = todos los dinos los controla la IA (modo demo y test de humo).
@export var autoplay: bool = false

var species_db: Dictionary = {}
var tuning: Dictionary = {}
var ball: Ball
var dinos: Array[Dino] = []
var match_state: MatchState
var phase: Phase = Phase.KICKOFF
var stats := {
	"kicks": 0, "impacts": 0, "knockdowns": 0, "knockouts": 0, "goals": 0, "possession_changes": 0
}

var _field: Dictionary = {}
var _camera: BroadcastCamera
var _hud: MatchHud
var _crowd: Crowd
var _referee: RefereePterosaur
var _player: PlayerController
var _sfx: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer3D] = []
var _sfx_index: int = 0
var _crowd_player: AudioStreamPlayer
var _phase_time: float = 0.0
var _kickoff_team: int = 0
var _steal_progress: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 7
	InputSetup.ensure_actions()
	species_db = GameData.load_species()
	tuning = GameData.load_tuning()
	_field = tuning["field"]
	_sfx = SfxSynth.build_all()
	StadiumBuilder.build_environment(self)
	var field_nodes := StadiumBuilder.build_field(self, _field, float(tuning["ball"]["radius"]))
	var areas: Array[Area3D] = field_nodes["goal_areas"]
	# La portería en -X es la del equipo 0: si entra ahí, marca el equipo 1.
	areas[0].body_entered.connect(_on_goal_area_entered.bind(1))
	areas[1].body_entered.connect(_on_goal_area_entered.bind(0))
	_crowd = StadiumBuilder.build_stands(self, _field, _rng)
	StadiumBuilder.build_scenery(self, _rng)
	_spawn_ball()
	_spawn_teams()
	_setup_audio()
	_setup_camera_and_hud()
	_referee = RefereePterosaur.new()
	_referee.follow_target = ball
	add_child(_referee)
	match_state = MatchState.new(float(tuning["match"]["prototype_duration_s"]))
	_hud.set_score(match_state.score, TEAM_NAMES)
	_start_kickoff()


# --- Consultas para la IA y el jugador -----------------------------------------------------


func goal_center(team: int) -> Vector3:
	var hl: float = _field["half_length"]
	return Vector3(-hl if team == 0 else hl, 0.0, 0.0)


func teammates_of(team: int) -> Array[Dino]:
	var result: Array[Dino] = []
	for dino in dinos:
		if dino.team == team:
			result.append(dino)
	return result


func closest_to_ball(team: int) -> Dino:
	var best: Dino = null
	var best_dist := INF
	for dino in teammates_of(team):
		if not dino.can_act():
			continue
		var dist := dino.global_position.distance_to(ball.global_position)
		if dist < best_dist:
			best_dist = dist
			best = dino
	return best


func best_pass_target(passer: Dino) -> Dino:
	for mate in teammates_of(passer.team):
		if mate == passer or not mate.can_act():
			continue
		var dist := mate.global_position.distance_to(passer.global_position)
		if dist > 6.0 and dist < 35.0:
			return mate
	return null


func half_length() -> float:
	return float(_field["half_length"])


func goal_half_width() -> float:
	return float(_field["goal_width"]) * 0.5


func clamp_to_field(point: Vector3, margin: float) -> Vector3:
	var hl: float = _field["half_length"]
	var hw: float = _field["half_width"]
	return Vector3(
		clampf(point.x, -hl + margin, hl - margin), 0.0, clampf(point.z, -hw + margin, hw - margin)
	)


# --- Construcción --------------------------------------------------------------------------


func _spawn_ball() -> void:
	ball = Ball.new()
	ball.setup(tuning["ball"])
	add_child(ball)


func _spawn_teams() -> void:
	var teams: Array = tuning["teams"]
	for team in 2:
		var ids: Array = teams[team]
		for slot in ids.size():
			var species_id: String = ids[slot]
			var dino := Dino.new()
			dino.setup(species_id, species_db[species_id], tuning, team, TEAM_COLORS[team])
			var pos: Vector3 = FORMATION[slot % FORMATION.size()]
			if team == 1:
				pos = Vector3(-pos.x, 0.0, -pos.z)
			var yaw := -PI * 0.5 if team == 0 else PI * 0.5
			dino.home_transform = Transform3D(Basis(Vector3.UP, yaw), pos + Vector3.UP * 0.05)
			dino.transform = dino.home_transform
			dino.ball = ball
			add_child(dino)
			dinos.append(dino)
			dino.impacted.connect(_on_dino_impacted)
			dino.knocked_out.connect(_on_dino_knocked_out)
			dino.kicked.connect(_on_dino_kicked)
			dino.dashed.connect(_on_dino_dashed)
			dino.stepped.connect(_on_dino_stepped)
			var ai := AiController.new()
			ai.setup(self, dino, 100 + dinos.size())
			add_child(ai)


func _setup_audio() -> void:
	for i in 12:
		var player := AudioStreamPlayer3D.new()
		player.unit_size = 18.0
		player.max_db = 3.0
		add_child(player)
		_sfx_players.append(player)
	_crowd_player = AudioStreamPlayer.new()
	_crowd_player.stream = _sfx["crowd"]
	_crowd_player.volume_db = -16.0
	add_child(_crowd_player)
	_crowd_player.play()


func _setup_camera_and_hud() -> void:
	_camera = BroadcastCamera.new()
	_camera.ball = ball
	_camera.field_half = Vector2(float(_field["half_length"]), float(_field["half_width"]))
	add_child(_camera)
	_camera.snap()
	_hud = MatchHud.new()
	add_child(_hud)
	_player = PlayerController.new()
	_player.setup(self, 0, _camera)
	add_child(_player)
	if not autoplay:
		_player.set_controlled(teammates_of(0)[0])


# --- Flujo del partido ---------------------------------------------------------------------


## Saque desde el centro: lo hace el equipo que encajó (al inicio, el equipo 0).
func _start_kickoff() -> void:
	phase = Phase.KICKOFF
	_phase_time = 0.0
	_steal_progress.clear()
	var ball_radius: float = float(tuning["ball"]["radius"])
	ball.reset_to(Vector3(0.0, ball_radius + 0.2, 0.0))
	var kicker: Dino = null
	for dino in dinos:
		if dino.is_out():
			continue
		if kicker == null and dino.team == _kickoff_team:
			kicker = dino
			var dir := 1.0 if dino.team == 0 else -1.0
			var back := dino.body_size().z * 0.5 + ball_radius + 0.15
			dino.reset_to(Transform3D(dino.home_transform.basis, Vector3(-dir * back, 0.05, 0.0)))
		else:
			dino.reset_to(dino.home_transform)
	if kicker != null and not autoplay and kicker.team == _player.team:
		_player.set_controlled(kicker)


func _physics_process(delta: float) -> void:
	_phase_time += delta
	match phase:
		Phase.KICKOFF:
			if _phase_time >= float(tuning["match"]["kickoff_delay_s"]):
				phase = Phase.PLAYING
				_whistle()
		Phase.PLAYING:
			match_state.tick(delta)
			if match_state.is_over():
				_end_match()
		Phase.GOAL:
			if _phase_time >= float(tuning["match"]["goal_celebration_s"]):
				_start_kickoff()
	if phase == Phase.PLAYING:
		_update_possession(delta)
		_check_bounds()
	_hud.set_clock(match_state.clock_text())
	_hud.set_player(_player.controlled, _camera.mode_name())


func _process(_delta: float) -> void:
	_crowd_player.volume_db = lerpf(-18.0, -4.0, _crowd.excitement)
	if Input.is_action_just_pressed("restart"):
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()


func _on_goal_area_entered(body: Node3D, scoring_team: int) -> void:
	if body != ball or phase != Phase.PLAYING:
		return
	match_state.register_goal(scoring_team)
	stats["goals"] = int(stats["goals"]) + 1
	_kickoff_team = 1 - scoring_team
	phase = Phase.GOAL
	_phase_time = 0.0
	ball.possessor = null
	_hud.set_score(match_state.score, TEAM_NAMES)
	_hud.show_banner("¡GOOOL %s!" % TEAM_NAMES[scoring_team], 2.6)
	_crowd.pulse(1.0)
	_camera.add_trauma(0.45)
	_play_sfx("cheer", ball.global_position, 6.0)
	_whistle()


func _end_match() -> void:
	phase = Phase.ENDED
	var winner := match_state.winner()
	var result := "EMPATE" if winner < 0 else "GANA %s" % TEAM_NAMES[winner]
	var score: Array[int] = match_state.score
	_hud.show_banner(
		"FINAL  %d - %d\n%s\nPulsa R para reiniciar" % [score[0], score[1], result], 9999.0
	)
	_crowd.pulse(0.8)
	_whistle()


# --- Posesión y robo -----------------------------------------------------------------------


func _update_possession(delta: float) -> void:
	var cfg: Dictionary = tuning["possession"]
	var holder := ball.possessor
	if holder != null:
		var drop: float = cfg["drop_distance"]
		if not holder.can_act() or holder.control_point().distance_to(ball.global_position) > drop:
			ball.possessor = null
			holder = null
	if holder == null:
		var best: Dino = null
		var best_dist := INF
		for dino in dinos:
			if not dino.can_act() or dino.just_kicked():
				continue
			var dist := dino.control_point().distance_to(ball.global_position)
			var rel_speed := (ball.linear_velocity - dino.linear_velocity).length()
			var height := ball.global_position.y - ball.radius
			var ok := PossessionRules.can_control(
				dist, rel_speed, height, dino.stat("control"), cfg
			)
			if ok and dist < best_dist:
				best_dist = dist
				best = dino
		if best != null:
			_set_possessor(best)
		return
	for dino in dinos:
		if dino.team == holder.team or not dino.can_act():
			continue
		var key := dino.get_instance_id()
		if dino.control_point().distance_to(ball.global_position) < float(cfg["steal_radius"]):
			var rate := PossessionRules.steal_rate(dino.stat("steal"), holder.stat("control"), cfg)
			_steal_progress[key] = float(_steal_progress.get(key, 0.0)) + rate * delta
			if float(_steal_progress[key]) >= 1.0:
				_steal_progress.clear()
				_set_possessor(dino)
				_hud.show_toast("¡Robo de %s!" % dino.display_name(), 1.2)
				return
		else:
			_steal_progress.erase(key)


func _set_possessor(dino: Dino) -> void:
	if ball.possessor == dino:
		return
	stats["possession_changes"] = int(stats["possession_changes"]) + 1
	ball.possessor = dino
	ball.last_touch_team = dino.team
	if not autoplay and dino.team == _player.team:
		_player.set_controlled(dino)


func _check_bounds() -> void:
	var hl: float = _field["half_length"]
	var hw: float = _field["half_width"]
	var limit_x: float = hl + float(_field["goal_depth"]) + 2.0
	var p := ball.global_position
	if absf(p.x) > limit_x or absf(p.z) > hw + 2.0 or p.y < -3.0:
		ball.reset_to(
			Vector3(clampf(p.x, -hl + 3.0, hl - 3.0), 3.0, clampf(p.z, -hw + 3.0, hw - 3.0))
		)
		_whistle()
	for dino in dinos:
		var d := dino.global_position
		if not dino.is_out() and (absf(d.x) > limit_x + 4.0 or absf(d.z) > hw + 6.0 or d.y < -5.0):
			dino.reset_to(dino.home_transform)


# --- Sensación de impacto ------------------------------------------------------------------


func _on_dino_impacted(victim: Dino, attacker: Dino, result: Dictionary) -> void:
	stats["impacts"] = int(stats["impacts"]) + 1
	var impact: float = result["impact"]
	var strength := clampf(impact / 20.0, 0.0, 1.0)
	var knockdown: bool = result["knockdown"]
	var contact := (victim.global_position + attacker.global_position) * 0.5
	var feel: Dictionary = tuning["feel"]
	_play_sfx(
		"hit_heavy" if strength > 0.35 else "hit_light",
		contact + Vector3.UP,
		2.0,
		lerpf(1.25, 0.7, clampf(attacker.mass / 8.0, 0.0, 1.0))
	)
	_camera.add_trauma(0.12 + strength * float(feel["shake_per_impact"]))
	_spawn_dust(contact + Vector3.UP * 0.3, 0.6 + strength)
	_crowd.pulse(0.08 + 0.3 * strength)
	if knockdown:
		stats["knockdowns"] = int(stats["knockdowns"]) + 1
		_hit_stop(lerpf(float(feel["hit_stop_min_s"]), float(feel["hit_stop_max_s"]), strength))
	if ball.possessor == victim and (knockdown or float(result["damage"]) > 8.0):
		# El balón sale suelto hacia un lado (no hacia la portería del derribado).
		var direction: Vector3 = result["direction"]
		var side := direction.cross(Vector3.UP).normalized() * (1.0 if _rng.randf() < 0.5 else -1.0)
		ball.kick(side * 5.0 + direction * 1.5 + Vector3.UP * 4.0, 0.0, attacker.team)


func _on_dino_knocked_out(dino: Dino) -> void:
	stats["knockouts"] = int(stats["knockouts"]) + 1
	_hud.show_toast("¡%s fuera de combate!" % dino.display_name(), 2.0)
	_crowd.pulse(0.5)
	_spawn_dust(dino.global_position + Vector3.UP * 0.5, 2.0)


func _on_dino_kicked(dino: Dino, part: String, power: float) -> void:
	stats["kicks"] = int(stats["kicks"]) + 1
	var pitch := 1.2 if part == "head" else (0.85 if part == "tail" else 1.0)
	_play_sfx("kick", ball.global_position, lerpf(-4.0, 3.0, power), pitch)
	if power > 0.8:
		_crowd.pulse(0.12)
	if dino.is_human:
		_camera.add_trauma(0.05 + 0.1 * power)


func _on_dino_dashed(dino: Dino) -> void:
	if str(dino.species["diet"]) == "carnivore":
		_play_sfx(
			"roar", dino.global_position, 0.0, lerpf(1.6, 0.8, clampf(dino.mass / 8.0, 0.0, 1.0))
		)


func _on_dino_stepped(dino: Dino) -> void:
	var weight := clampf(dino.mass / 8.0, 0.1, 1.0)
	_play_sfx("step", dino.global_position, linear_to_db(weight) - 6.0, lerpf(1.5, 0.6, weight))
	if dino.mass >= 6.0:
		_camera.add_trauma(0.03)


func _hit_stop(duration: float) -> void:
	if autoplay:
		return
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func _spawn_dust(pos: Vector3, amount_scale: float) -> void:
	var dust := CPUParticles3D.new()
	dust.one_shot = true
	dust.explosiveness = 0.9
	dust.amount = int(16 * amount_scale) + 4
	dust.lifetime = 0.9
	dust.direction = Vector3.UP
	dust.spread = 70.0
	dust.initial_velocity_min = 2.0
	dust.initial_velocity_max = 5.0 * amount_scale
	dust.gravity = Vector3(0, -3.0, 0)
	dust.scale_amount_min = 0.4
	dust.scale_amount_max = 1.0 * amount_scale
	var puff := SphereMesh.new()
	puff.radius = 0.25
	puff.height = 0.5
	puff.radial_segments = 6
	puff.rings = 3
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.72, 0.62, 0.45, 0.7)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = material
	dust.mesh = puff
	dust.position = pos
	add_child(dust)
	dust.emitting = true
	get_tree().create_timer(1.5).timeout.connect(dust.queue_free)


func _play_sfx(sfx_name: String, pos: Vector3, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if not _sfx.has(sfx_name):
		return
	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	player.stream = _sfx[sfx_name]
	player.global_position = pos
	player.volume_db = volume_db
	player.pitch_scale = pitch * _rng.randf_range(0.94, 1.06)
	player.play()


func _whistle() -> void:
	_referee.whistle()
	_play_sfx("whistle", _referee.global_position, 4.0)
