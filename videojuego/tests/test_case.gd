extends RefCounted
## Base mínima de tests (sin dependencias externas). Los tests heredan de este script.

var failures: PackedStringArray = PackedStringArray()


func reset_case() -> void:
	failures = PackedStringArray()


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append("se esperaba true. %s" % message)


func assert_false(condition: bool, message: String = "") -> void:
	if condition:
		failures.append("se esperaba false. %s" % message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		failures.append("se esperaba %s, se obtuvo %s. %s" % [expected, actual, message])


func assert_almost(
	actual: float, expected: float, tolerance: float = 0.001, message: String = ""
) -> void:
	if absf(actual - expected) > tolerance:
		failures.append("se esperaba ~%s, se obtuvo %s. %s" % [expected, actual, message])


func assert_gt(actual: float, threshold: float, message: String = "") -> void:
	if not actual > threshold:
		failures.append("se esperaba %s > %s. %s" % [actual, threshold, message])


func assert_lt(actual: float, threshold: float, message: String = "") -> void:
	if not actual < threshold:
		failures.append("se esperaba %s < %s. %s" % [actual, threshold, message])
