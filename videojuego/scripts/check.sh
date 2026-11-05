#!/usr/bin/env bash
# Punto de entrada único de verificación (lint + tests) para agentes y CI.
# Detecta el motor por los archivos del proyecto. Amplíalo al aceptar ADR-0001.
set -euo pipefail
cd "$(dirname "$0")/.."

ran=0
if [[ -f project.godot ]]; then
  echo "▶ Godot detectado"
  if command -v gdformat >/dev/null; then gdformat --check src/ tests/; else echo "⚠ gdformat no instalado (pip install gdtoolkit)"; fi
  if command -v gdlint >/dev/null; then gdlint src/ tests/; else echo "⚠ gdlint no instalado (pip install gdtoolkit)"; fi
  GODOT_BIN="${GODOT_BIN:-godot}"
  if command -v "$GODOT_BIN" >/dev/null && [[ -d addons/gut ]]; then
    "$GODOT_BIN" --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
  else
    echo "⚠ Godot o GUT no disponibles: tests omitidos"
  fi
  ran=1
fi
if [[ -f package.json ]]; then
  echo "▶ Proyecto JS/TS detectado"
  npm run --if-present lint
  npm test --if-present
  ran=1
fi
if [[ -f pyproject.toml || -f requirements.txt ]]; then
  echo "▶ Proyecto Python detectado"
  command -v ruff >/dev/null && ruff check src tests
  python -m pytest -q tests
  ran=1
fi

if [[ $ran -eq 0 ]]; then
  echo "⚠ Aún no hay motor configurado (ver docs/adr/0001-eleccion-de-motor.md). Nada que verificar."
fi
echo "✔ check.sh terminado"
