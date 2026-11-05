extends SceneTree
## Runner de tests: ejecuta los métodos test_* de cada tests/test_*.gd.
## Uso: godot --headless --path . -s res://tests/run_tests.gd

const TESTS_DIR := "res://tests"


func _initialize() -> void:
	var total := 0
	var failed := 0
	var files := Array(DirAccess.get_files_at(TESTS_DIR))
	files.sort()
	for file_name: String in files:
		if not (file_name.begins_with("test_") and file_name.ends_with(".gd")):
			continue
		if file_name == "test_case.gd":
			continue
		var script: GDScript = load("%s/%s" % [TESTS_DIR, file_name])
		var suite: Object = script.new()
		for method in suite.get_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			total += 1
			suite.call("reset_case")
			suite.call(method_name)
			var failures: PackedStringArray = suite.get("failures")
			if failures.is_empty():
				print("  ok    %s::%s" % [file_name, method_name])
			else:
				failed += 1
				print("  FALLO %s::%s" % [file_name, method_name])
				for failure in failures:
					print("        - %s" % failure)
	print("\n%d tests, %d fallos" % [total, failed])
	quit(1 if failed > 0 or total == 0 else 0)
