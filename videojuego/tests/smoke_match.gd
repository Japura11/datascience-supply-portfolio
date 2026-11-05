extends SceneTree
## Test de humo: juega un partido IA vs IA ~60 s simulados (usar con --fixed-fps 60) y
## comprueba que la jugabilidad básica ocurre: golpeos, choques y cambios de posesión.

const FRAMES := 3600

var _director: MatchDirector
var _frame: int = 0


func _initialize() -> void:
	var scene: PackedScene = load("res://src/game/main.tscn")
	_director = scene.instantiate()
	_director.autoplay = true
	root.add_child(_director)


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame < FRAMES:
		return false
	var stats: Dictionary = _director.stats
	print("Estadísticas del partido simulado: %s" % stats)
	print("Marcador: %s" % [_director.match_state.score])
	var ok := int(stats["kicks"]) > 0 and int(stats["possession_changes"]) > 0
	ok = ok and int(stats["impacts"]) > 0
	print("SMOKE %s" % ("OK" if ok else "FALLO: la IA no generó jugadas"))
	quit(0 if ok else 1)
	return true
