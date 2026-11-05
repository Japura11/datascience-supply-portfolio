#!/usr/bin/env bash
# Punto de entrada único de verificación (formato + lint + tests + partido de humo).
# Uso: scripts/check.sh            (Godot en el PATH como "godot")
#      GODOT_BIN=/ruta/a/godot scripts/check.sh
# En Windows (PowerShell): scripts\check.ps1
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
step() { echo; echo "▶ $1"; }

if [[ ! -f project.godot ]]; then
  echo "⚠ No hay project.godot: nada que verificar."
  exit 0
fi

step "Formato (gdformat)"
if command -v gdformat >/dev/null; then
  gdformat --check src/ tests/ || fail=1
else
  echo "⚠ gdformat no instalado (pip install gdtoolkit==4.*)"
fi

step "Lint (gdlint)"
if command -v gdlint >/dev/null; then
  gdlint src/ tests/ || fail=1
else
  echo "⚠ gdlint no instalado (pip install gdtoolkit==4.*)"
fi

GODOT_BIN="${GODOT_BIN:-godot}"
if ! command -v "$GODOT_BIN" >/dev/null; then
  echo "⚠ Godot no encontrado: define GODOT_BIN. Tests omitidos."
  exit $fail
fi

# Ejecuta Godot y falla si el código de salida != 0 o si hay errores de script en la salida.
run_godot() {
  local log code=0
  log=$("$GODOT_BIN" --headless --path . "$@" 2>&1) || code=$?
  echo "$log" | grep -vE "^\s*$|Godot Engine v|ObjectDB instances leaked|at: cleanup"
  if [[ $code -ne 0 ]] || grep -qE "SCRIPT ERROR|Parse Error" <<<"$log"; then
    return 1
  fi
}

step "Importar proyecto"
"$GODOT_BIN" --headless --path . --import >/dev/null 2>&1 || true

step "Tests de reglas (tests/test_*.gd)"
run_godot -s res://tests/run_tests.gd || fail=1

step "Partido de humo IA vs IA (60 s simulados)"
run_godot --fixed-fps 60 -s res://tests/smoke_match.gd || fail=1

echo
if [[ $fail -eq 0 ]]; then echo "✔ check.sh: todo en verde"; else echo "✘ check.sh: hay fallos"; fi
exit $fail
