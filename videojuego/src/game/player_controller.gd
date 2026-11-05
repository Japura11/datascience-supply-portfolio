class_name PlayerController
extends Node
## Teclado/ratón → dino controlado del equipo humano. Movimiento relativo a la cámara.

const KICK_ACTIONS := {"kick_foot": "foot", "kick_tail": "tail", "kick_head": "head"}

var director: MatchDirector
var team: int = 0
var camera: BroadcastCamera
var controlled: Dino


func setup(p_director: MatchDirector, p_team: int, p_camera: BroadcastCamera) -> void:
	director = p_director
	team = p_team
	camera = p_camera


func set_controlled(dino: Dino) -> void:
	if controlled == dino or dino == null:
		return
	if controlled != null:
		controlled.set_human(false)
		controlled.move_input = Vector3.ZERO
		controlled.wants_sprint = false
		controlled.cancel_charge()
	controlled = dino
	controlled.set_human(true)
	camera.target_dino = controlled


func switch_to_best() -> void:
	var best: Dino = null
	var best_dist := INF
	for dino in director.teammates_of(team):
		if dino == controlled or dino.is_out():
			continue
		var dist := dino.global_position.distance_to(director.ball.global_position)
		if dist < best_dist:
			best_dist = dist
			best = dino
	if best != null:
		set_controlled(best)


func _physics_process(_delta: float) -> void:
	if controlled == null or director.autoplay:
		return
	if Input.is_action_just_pressed("toggle_camera"):
		camera.toggle_mode()
	if controlled.is_out() or Input.is_action_just_pressed("switch_player"):
		switch_to_best()
	var raw := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var basis := camera.global_transform.basis
	var forward := Vector3(-basis.z.x, 0.0, -basis.z.z).normalized()
	var right := Vector3(basis.x.x, 0.0, basis.x.z).normalized()
	controlled.move_input = right * raw.x - forward * raw.y
	controlled.wants_sprint = Input.is_action_pressed("sprint")
	for action: String in KICK_ACTIONS:
		var part: String = KICK_ACTIONS[action]
		if Input.is_action_just_pressed(action):
			controlled.start_charge(part)
		elif Input.is_action_just_released(action) and controlled.charge_part == part:
			controlled.release_kick()
	if Input.is_action_just_pressed("tackle"):
		controlled.try_dash()
