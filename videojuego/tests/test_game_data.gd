extends "res://tests/test_case.gd"


func test_species_are_valid() -> void:
	var species := GameData.load_species()
	assert_gt(species.size(), 0, "hay especies")
	for species_id: String in species:
		var errors := GameData.validate_species(species_id, species[species_id])
		assert_true(errors.is_empty(), ", ".join(errors))


func test_prototype_teams_reference_existing_species() -> void:
	var species := GameData.load_species()
	var teams: Array = GameData.load_tuning()["teams"]
	assert_eq(teams.size(), 2)
	for team: Array in teams:
		for species_id: String in team:
			assert_true(species.has(species_id), "especie '%s' no existe" % species_id)


func test_validation_catches_bad_entry() -> void:
	var errors := GameData.validate_species("rota", {"name": "Rota"})
	assert_gt(errors.size(), 0)
