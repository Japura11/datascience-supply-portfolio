class_name MatchHud
extends CanvasLayer
## Interfaz del partido: marcador, reloj, dino controlado (aguante y carga) y avisos.

const HELP_TEXT := (
	"WASD mover · Shift sprint · Espacio embestida · Q cambiar dino · C cámara · R reiniciar\n"
	+ "J / clic izq. PATA · K / clic der. COLA · L / clic central CABEZA"
	+ "   (mantén = potencia · A/D al soltar = curva)"
)

var _score: Label
var _clock: Label
var _banner: Label
var _toast: Label
var _player_name: Label
var _stamina_bar: ProgressBar
var _charge_bar: ProgressBar
var _camera_label: Label
var _banner_time: float = 0.0
var _toast_time: float = 0.0


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var top := VBoxContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_top = 12
	root.add_child(top)
	_score = _label(top, "AZUL 0 - 0 ROJO", 40)
	_clock = _label(top, "5:00", 26)
	var panel := VBoxContainer.new()
	panel.position = Vector2(24, 20)
	panel.custom_minimum_size = Vector2(260, 0)
	root.add_child(panel)
	_player_name = _label(panel, "", 24, HORIZONTAL_ALIGNMENT_LEFT)
	_stamina_bar = _bar(panel, Color(0.35, 0.9, 0.4))
	_label(panel, "Carga del golpe", 16, HORIZONTAL_ALIGNMENT_LEFT)
	_charge_bar = _bar(panel, Color(1.0, 0.75, 0.2))
	_camera_label = _label(panel, "", 16, HORIZONTAL_ALIGNMENT_LEFT)
	var help := _label(root, HELP_TEXT, 17, HORIZONTAL_ALIGNMENT_CENTER)
	help.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	help.grow_vertical = Control.GROW_DIRECTION_BEGIN
	help.offset_bottom = -14
	_banner = _label(root, "", 64)
	_banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner.visible = false
	_toast = _label(root, "", 26)
	_toast.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_toast.offset_top = 120
	_toast.visible = false


func set_score(score: Array[int], team_names: Array[String]) -> void:
	_score.text = "%s %d - %d %s" % [team_names[0], score[0], score[1], team_names[1]]


func set_clock(text: String) -> void:
	_clock.text = text


func set_player(dino: Dino, camera_mode: String) -> void:
	if dino == null:
		return
	_player_name.text = (
		"Controlas: %s%s" % [dino.display_name(), " (herido)" if dino.stamina.is_injured() else ""]
	)
	_stamina_bar.value = dino.stamina.fraction() * 100.0
	_charge_bar.value = dino.charge_amount * 100.0
	_camera_label.text = "Cámara: %s" % camera_mode


func show_banner(text: String, seconds: float) -> void:
	_banner.text = text
	_banner.visible = true
	_banner_time = seconds


func show_toast(text: String, seconds: float = 2.0) -> void:
	_toast.text = text
	_toast.visible = true
	_toast_time = seconds


func _process(delta: float) -> void:
	if _banner_time > 0.0:
		_banner_time -= delta
		_banner.visible = _banner_time > 0.0
	if _toast_time > 0.0:
		_toast_time -= delta
		_toast.visible = _toast_time > 0.0


func _label(
	parent: Control,
	text: String,
	font_size: int,
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER
) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("outline_size", 8)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _bar(parent: Control, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(240, 16)
	bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.5)
	bar.add_theme_stylebox_override("background", bg)
	parent.add_child(bar)
	return bar
