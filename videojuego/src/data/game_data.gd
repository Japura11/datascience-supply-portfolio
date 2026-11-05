class_name GameData
extends RefCounted
## Carga y valida los datos de diseño (especies y tuning) desde JSON.

const SPECIES_PATH := "res://src/data/species.json"
const TUNING_PATH := "res://src/data/tuning.json"
const REQUIRED_FIELDS: Array[String] = [
	"name",
	"skeleton",
	"diet",
	"mass",
	"max_speed",
	"accel",
	"turn_rate_deg",
	"forward_bias",
	"aim_freedom",
	"stamina",
	"body",
	"stats",
	"color",
]
const STAT_NAMES: Array[String] = ["attack", "steal", "defense", "control", "finishing"]
const SKELETONS: Array[String] = ["biped", "quadruped"]


static func load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("GameData: no se pudo leer %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	push_error("GameData: JSON inválido en %s" % path)
	return {}


static func load_species() -> Dictionary:
	return load_json(SPECIES_PATH)


static func load_tuning() -> Dictionary:
	return load_json(TUNING_PATH)


static func validate_species(species_id: String, entry: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for field in REQUIRED_FIELDS:
		if not entry.has(field):
			errors.append("%s: falta el campo '%s'" % [species_id, field])
	if errors.size() > 0:
		return errors
	if float(entry["mass"]) <= 0.0:
		errors.append("%s: la masa debe ser > 0" % species_id)
	if not SKELETONS.has(str(entry["skeleton"])):
		errors.append("%s: esqueleto desconocido '%s'" % [species_id, entry["skeleton"]])
	var stats: Dictionary = entry["stats"]
	for stat_name in STAT_NAMES:
		var value: int = int(stats.get(stat_name, 0))
		if value < 1 or value > 5:
			errors.append("%s: atributo '%s' fuera de 1-5" % [species_id, stat_name])
	var body: Dictionary = entry["body"]
	for dim in ["width", "height", "length"]:
		if float(body.get(dim, 0.0)) <= 0.0:
			errors.append("%s: dimensión '%s' inválida" % [species_id, dim])
	return errors
