#!/usr/bin/env bash
# Punto de entrada único de verificación (lint + tests) para agentes y CI.
# Detecta el motor por los archivos del proyecto. Amplíalo al aceptar ADR-0001.
set -euo pipefail
cd "$(dirname "$0")/.."

ran=0
if [[ -f project.godot ]]; then
  echo "▶ Godot detectado"
  command -v gdlint >/dev/null && { gdlint src/ ; ran=1; }
  # Tests (GUT): godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
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
