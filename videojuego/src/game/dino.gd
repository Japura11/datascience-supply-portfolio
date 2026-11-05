class_name Dino
extends RigidBody3D
## Dinosaurio jugador: cuerpo físico con masa e inercia, choques, golpeo y derribo.
## Las reglas viven en src/logic/ (testeables); aquí solo se aplican al cuerpo.

signal impacted(victim: Dino, attacker: Dino, result: Dictionary)
signal knocked_out(dino: Dino)
signal kicked(dino: Dino, part: String, power: float)
signal dashed(dino: Dino)
signal stepped(dino: Dino)

var species_id: String = ""
var species: Dictionary = {}
var tuning: Dictionary = {}
var team: int = 0
var team_color := Color.WHITE
var stamina: Stamina
var ball: Ball
var home_transform := Transform3D.IDENTITY
var is_human: bool = false
var move_input := Vector3.ZERO
var wants_sprint: bool = false
var charge_part: String = ""
var charge_amount: float = 0.0

var _size := Vector3.ONE
var _model: DinoModel
var _ring: MeshInstance3D
var _name_label: Label3D
var _bar_label: Label3D
var _prev_velocity := Vector3.ZERO
var _impact_cooldowns: Dictionary = {}
var _is_knocked: bool = false
var _knocked_time: float = 0.0
var _getting_up: bool = false
var _out_time: float = 0.0
var _stagger_time: float = 0.0
var _dash_time: float = 0.0
var _dash_cooldown: float = 0.0
var _kick_cooldown: float = 0.0
var _pending_reset: bool = false
var _reset_target := Transform3D.IDENTITY
var _step_distance: float = 0.0
var _rng := RandomNumberGenerator.new()
var _mat_standing := PhysicsMaterial.new()
var _mat_knocked := PhysicsMaterial.new()


func setup(
	p_species_id: String, p_species: Dictionary, p_tuning: Dictionary, p_team: int, p_color: Color
) -> void:
	species_id = p_species_id
	species = p_species
	tuning = p_tuning
	team = p_team
	team_color = p_color
	var body: Dictionary = species["body"]
	_size = Vector3(float(body["width"]), float(body["height"]), float(body["length"]))
	var st: Dictionary = tuning["stamina"]
	stamina = Stamina.new(
		float(species["stamina"]),
		float(st["regen_delay_s"]),
		float(st["regen_fraction_per_s"]),
		float(st["injured_threshold"])
	)
	name = "%s_%d" % [species_id, team]
	_rng.seed = hash(name)


func _ready() -> void:
	mass = float(species["mass"])
	can_sleep = false
	contact_monitor = true
	max_contacts_reported = 8
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	angular_damp = 3.0
	_mat_standing.friction = 0.05
	_mat_knocked.friction = 0.8
	_mat_knocked.bounce = 0.1
	physics_material_override = _mat_standing
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var is_quad: bool = str(species["skeleton"]) == "quadruped"
	box.size = Vector3(
		_size.x, _size.y * (0.85 if is_quad else 0.9), _size.z * (0.8 if is_quad else 0.7)
	)
	shape.shape = box
	shape.position = Vector3(0.0, box.size.y * 0.5, -_size.z * 0.05)
	add_child(shape)
	_model = DinoModel.new()
	add_child(_model)
	_model.build(species, team_color)
	_build_overlays()
	body_entered.connect(_on_body_entered)


# --- Consultas -----------------------------------------------------------------------------


func stat(stat_name: String) -> int:
	var stats: Dictionary = species["stats"]
	return int(stats.get(stat_name, 1))


func display_name() -> String:
	return str(species["name"])


func body_size() -> Vector3:
	return _size


func can_act() -> bool:
	return not (_is_knocked or _getting_up or is_out())


func is_out() -> bool:
	return _out_time > 0.0


func is_knocked() -> bool:
	return _is_knocked


func is_dashing() -> bool:
	return _dash_time > 0.0


func just_kicked() -> bool:
	return _kick_cooldown > 0.0


func dash_ready() -> bool:
	return _dash_cooldown <= 0.0


func prev_velocity() -> Vector3:
	return _prev_velocity


func facing() -> Vector3:
	var f := -global_transform.basis.z
	f.y = 0.0
	if f.length() < 0.01:
		return Vector3.FORWARD
	return f.normalized()


func current_max_speed() -> float:
	var speed: float = float(species["max_speed"])
	if wants_sprint:
		speed *= float(tuning["sprint"]["speed_mult"])
	if stamina.is_injured():
		speed *= float(tuning["stamina"]["injured_speed_mult"])
	if ball != null and ball.possessor == self:
		speed *= float(tuning["possession"]["dribble_speed_mult"])
	return speed


## Punto delante del hocico/patas donde se conduce el balón.
func control_point() -> Vector3:
	var ball_radius: float = float(tuning["ball"]["radius"])
	var ahead: float = _size.z * 0.5 + ball_radius + 0.1
	return global_position + facing() * ahead + Vector3.UP * ball_radius


# --- Acciones ------------------------------------------------------------------------------


func set_human(value: bool) -> void:
	is_human = value
	if _ring:
		_ring.visible = value


func start_charge(part: String) -> void:
	if can_act():
		charge_part = part
		charge_amount = 0.0


func cancel_charge() -> void:
	charge_part = ""
	charge_amount = 0.0


## Suelta el golpe cargado. Devuelve true si llegó a tocar el balón.
func release_kick() -> bool:
	if charge_part == "":
		return false
	var part := charge_part
	var charge := charge_amount
	cancel_charge()
	if not can_act() or _kick_cooldown > 0.0:
		return false
	var kick_cfg: Dictionary = tuning["kick"]
	_kick_cooldown = float(kick_cfg["cooldown_s"])
	_model.play_kick(part)
	if ball == null:
		return false
	var to_ball := ball.global_position - control_point()
	var reach: float = float(kick_cfg["reach"]) + _size.x * 0.3
	var max_height: float = _size.y + 1.0 if part == "head" else 1.6
	if Vector2(to_ball.x, to_ball.z).length() > reach or ball.global_position.y > max_height:
		return false
	var f := facing()
	var aim := KickRules.aim_direction(f, move_input, float(species["aim_freedom"]))
	var noise := _rng.randf_range(-1.0, 1.0)
	aim = KickRules.apply_aim_error(aim, charge, stat("finishing"), noise, kick_cfg)
	var kick := KickRules.compute(part, charge, stat("finishing"), kick_cfg["parts"])
	var spin := KickRules.curve_spin(f, move_input, float(kick["curve"]))
	ball.kick(KickRules.launch_velocity(aim, kick), spin, team)
	kicked.emit(self, part, charge)
	return true


## Embestida (botón de choque): impulso hacia delante que multiplica el daño del impacto.
func try_dash() -> bool:
	if not can_act() or _dash_cooldown > 0.0:
		return false
	var cfg: Dictionary = tuning["tackle"]
	apply_central_impulse(facing() * float(cfg["impulse_speed"]) * mass)
	_dash_time = float(cfg["duration_s"])
	_dash_cooldown = float(cfg["cooldown_s"])
	_model.play_tackle()
	dashed.emit(self)
	return true


func reset_to(xform: Transform3D) -> void:
	cancel_charge()
	_is_knocked = false
	_getting_up = false
	_stagger_time = 0.0
	_dash_time = 0.0
	_lock_upright(true)
	physics_material_override = _mat_standing
	linear_damp = 0.0
	_reset_target = xform
	_pending_reset = true


# --- Física --------------------------------------------------------------------------------


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	if is_out():
		return
	stamina.tick(delta)
	if charge_part != "":
		charge_amount = minf(1.0, charge_amount + delta / float(tuning["kick"]["charge_time_s"]))
	var flat_speed := Vector2(linear_velocity.x, linear_velocity.z).length()
	_model.animate(delta, flat_speed, float(species["max_speed"]), _is_knocked)
	_update_overlays()
	if can_act():
		_step_distance += flat_speed * delta
		if _step_distance > _size.y * 0.9:
			_step_distance = 0.0
			stepped.emit(self)
	_prev_velocity = linear_velocity


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _pending_reset:
		state.transform = _reset_target
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		_pending_reset = false
		return
	if _getting_up:
		_stand_up(state)
		return
	if not can_act() or _stagger_time > 0.0 or _dash_time > 0.0:
		return
	_drive(state)


## Movimiento con inercia: aceleración limitada, sesgo hacia delante y radio de giro por especie.
func _drive(state: PhysicsDirectBodyState3D) -> void:
	var dt := state.step
	var v := state.linear_velocity
	var flat_v := Vector3(v.x, 0.0, v.z)
	var f := facing()
	var input := Vector3(move_input.x, 0.0, move_input.z).limit_length(1.0)
	var desired := Vector3.ZERO
	if input.length() > 0.05:
		var forward_only := f * input.length() * maxf(f.dot(input.normalized()), 0.0)
		desired = input.lerp(forward_only, float(species["forward_bias"])) * current_max_speed()
	var dv := (desired - flat_v).limit_length(float(species["accel"]) * dt)
	state.linear_velocity = v + dv
	var turn_rate: float = deg_to_rad(float(species["turn_rate_deg"]))
	if wants_sprint:
		turn_rate *= float(tuning["sprint"]["turn_mult"])
	var yaw_rate := 0.0
	if input.length() > 0.05:
		var angle := f.signed_angle_to(input.normalized(), Vector3.UP)
		yaw_rate = clampf(angle * 10.0, -turn_rate, turn_rate)
	state.angular_velocity = Vector3(0.0, yaw_rate, 0.0)


func _stand_up(state: PhysicsDirectBodyState3D) -> void:
	var f := facing()
	var yaw := atan2(-f.x, -f.z)
	var origin := state.transform.origin
	origin.y = maxf(origin.y, 0.0) + 0.1
	state.transform = Transform3D(Basis(Vector3.UP, yaw), origin)
	state.angular_velocity = Vector3.ZERO
	_getting_up = false
	_lock_upright.call_deferred(true)


func _update_timers(delta: float) -> void:
	for key: int in _impact_cooldowns.keys():
		_impact_cooldowns[key] = float(_impact_cooldowns[key]) - delta
		if float(_impact_cooldowns[key]) <= 0.0:
			_impact_cooldowns.erase(key)
	_kick_cooldown = maxf(0.0, _kick_cooldown - delta)
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)
	_dash_time = maxf(0.0, _dash_time - delta)
	_stagger_time = maxf(0.0, _stagger_time - delta)
	if _is_knocked:
		_knocked_time -= delta
		if _knocked_time <= 0.0 and linear_velocity.length() < 2.5:
			_is_knocked = false
			_getting_up = true
			physics_material_override = _mat_standing
			linear_damp = 0.0
	if is_out():
		_out_time -= delta
		if _out_time <= 0.0:
			_return_to_play()


# --- Choques -------------------------------------------------------------------------------


func _on_body_entered(body: Node) -> void:
	if not body is Dino:
		return
	var other := body as Dino
	if other.team == team or is_out() or other.is_out():
		return
	var key := other.get_instance_id()
	if _impact_cooldowns.has(key):
		return
	var impact_cfg: Dictionary = tuning["impact"]
	_impact_cooldowns[key] = float(impact_cfg["pair_cooldown_s"])
	var direction := global_position - other.global_position
	direction.y = 0.0
	direction = direction.normalized() if direction.length() > 0.01 else other.facing()
	# Cada dino calcula el daño que RECIBE según la velocidad con la que el otro venía hacia él.
	var result := (
		ImpactRules
		. compute(
			{
				"mass": other.mass,
				"closing_speed": other.prev_velocity().dot(direction),
				"attack": other.stat("attack"),
				"charging": other.is_dashing(),
			},
			{"mass": mass, "defense": stat("defense"), "max_stamina": stamina.max_value},
			impact_cfg
		)
	)
	var damage: float = result["damage"]
	var knockdown: bool = result["knockdown"]
	if damage <= 0.0 and not knockdown:
		return
	result["direction"] = direction
	stamina.apply_damage(damage)
	if stamina.is_depleted():
		_go_out.call_deferred()
	elif knockdown:
		_knock_down.call_deferred(direction * float(result["knockback_speed"]))
	else:
		_stagger_time = float(impact_cfg["stagger_s"])
	impacted.emit(self, other, result)


func _knock_down(push: Vector3) -> void:
	if _is_knocked or is_out():
		return
	_is_knocked = true
	var base_time: float = float(tuning["impact"]["knockdown_base_s"])
	_knocked_time = base_time * (1.2 - 0.06 * float(stat("defense")))
	cancel_charge()
	_lock_upright(false)
	physics_material_override = _mat_knocked
	linear_damp = 0.8
	apply_central_impulse((push + Vector3.UP * 3.0) * mass)
	var axis := Vector3.UP.cross(push)
	if axis.length() < 0.01:
		axis = Vector3.RIGHT
	angular_velocity = axis.normalized() * 5.0


func _go_out() -> void:
	if is_out():
		return
	_is_knocked = false
	_getting_up = false
	cancel_charge()
	_out_time = float(tuning["stamina"]["out_of_play_s"])
	visible = false
	freeze = true
	collision_layer = 0
	collision_mask = 0
	knocked_out.emit(self)


func _return_to_play() -> void:
	_out_time = 0.0
	stamina.refill()
	global_transform = home_transform
	_lock_upright(true)
	physics_material_override = _mat_standing
	linear_damp = 0.0
	collision_layer = 1
	collision_mask = 1
	visible = true
	freeze = false
	reset_to(home_transform)


func _lock_upright(locked: bool) -> void:
	axis_lock_angular_x = locked
	axis_lock_angular_z = locked


# --- Indicadores ---------------------------------------------------------------------------


func _build_overlays() -> void:
	_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	var radius: float = maxf(_size.x, _size.z) * 0.45
	torus.inner_radius = radius
	torus.outer_radius = radius + 0.18
	var ring_material := StandardMaterial3D.new()
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.albedo_color = Color(1.0, 0.9, 0.2)
	torus.material = ring_material
	_ring.mesh = torus
	_ring.position = Vector3(0, 0.05, 0)
	_ring.scale = Vector3(1.0, 0.15, 1.0)
	_ring.visible = is_human
	add_child(_ring)
	_name_label = _make_label(display_name(), 56, _size.y + 1.0)
	_name_label.modulate = team_color.lightened(0.35)
	_bar_label = _make_label("", 44, _size.y + 0.6)


func _make_label(text: String, font_size: int, height: float) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = font_size
	label.outline_size = 10
	label.pixel_size = 0.012
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = Vector3(0, height, 0)
	add_child(label)
	return label


func _update_overlays() -> void:
	var keep_upright := global_transform.basis.inverse()
	_name_label.position = keep_upright * Vector3(0, _size.y + 1.0, 0)
	_bar_label.position = keep_upright * Vector3(0, _size.y + 0.6, 0)
	var fraction := stamina.fraction()
	var filled := int(round(fraction * 10.0))
	_bar_label.text = "█".repeat(filled) + "░".repeat(10 - filled)
	if fraction > 0.5:
		_bar_label.modulate = Color(0.4, 1.0, 0.4)
	elif fraction > 0.25:
		_bar_label.modulate = Color(1.0, 0.85, 0.2)
	else:
		_bar_label.modulate = Color(1.0, 0.3, 0.25)
