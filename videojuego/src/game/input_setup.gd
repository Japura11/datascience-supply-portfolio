class_name InputSetup
extends RefCounted
## Registra las acciones de entrada por código (teclado y ratón). Ver docs/design/controles.md.

const KEY_BINDINGS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"kick_foot": [KEY_J],
	"kick_tail": [KEY_K],
	"kick_head": [KEY_L],
	"tackle": [KEY_SPACE],
	"sprint": [KEY_SHIFT],
	"switch_player": [KEY_Q],
	"toggle_camera": [KEY_C],
	"restart": [KEY_R],
}
const MOUSE_BINDINGS := {
	"kick_foot": [MOUSE_BUTTON_LEFT],
	"kick_tail": [MOUSE_BUTTON_RIGHT],
	"kick_head": [MOUSE_BUTTON_MIDDLE],
}


static func ensure_actions() -> void:
	for action: String in KEY_BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key: Key in KEY_BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	for action: String in MOUSE_BINDINGS:
		for button: MouseButton in MOUSE_BINDINGS[action]:
			var event := InputEventMouseButton.new()
			event.button_index = button
			InputMap.action_add_event(action, event)
