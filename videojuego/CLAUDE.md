# CLAUDE.md — Proyecto Videojuego

Memoria del proyecto para Claude Code. Se carga en cada sesión iniciada en
`videojuego/` (o al trabajar en archivos de esta carpeta). Mantenla corta:
lo que no cambie decisiones va en `docs/`.

## Estado actual

- **Fase:** Prototipo 1 jugable (campo plano, 2 vs 2). Siguiente: playtest humano → Prototipo 2.
- **Juego:** fútbol arcade 3D de dinosaurios con físicas, furia, eliminaciones y banquillo. PC, comercial. Equipo: 1 persona + Claude. Plazo: 6–12 meses.
- **Motor / lenguaje:** **Godot 4 + GDScript tipado** (ADR-0001 aceptado). Tests: GUT. Lint: gdtoolkit.
- El usuario viene de Python/data y es nuevo en motores: explica los conceptos de Godot
  (nodos, escenas, señales, `_physics_process`) la primera vez que aparezcan.
- El usuario desarrolla en **Windows**: instrucciones y rutas para Windows (PowerShell).
- **Documento de diseño:** `docs/GDD.md` (fuente de verdad del diseño).

## Cómo trabajamos (resumen; detalle en `docs/WORKFLOW.md`)

1. Toda feature nace como ficha en `docs/design/` (skill `/nueva-feature`).
2. El diseño se aprueba **antes** de programar. El código sigue a la ficha, no al revés.
3. Cambios pequeños y verticales: una feature jugable a la vez.
4. Antes de dar algo por terminado: `scripts/check.sh` en verde + `/revisar-cambios`.
5. Decisiones técnicas difíciles de revertir → ADR en `docs/adr/`.

## Agentes disponibles (`.claude/agents/`)

| Agente | Úsalo para |
|---|---|
| `productor` | Priorizar backlog, partir features en tareas, planificar hitos |
| `disenador-juego` | Mecánicas, reglas, loops, GDD, fichas de feature |
| `disenador-niveles` | Layout, ritmo, curva de dificultad, encuentros |
| `narrativa` | Lore, diálogos, textos de UI, tono |
| `arquitecto-motor` | Arquitectura, ADRs, estructura de carpetas, patrones |
| `programador-gameplay` | Implementar mecánicas según la ficha aprobada |
| `pipeline-assets` | Convenciones de assets, importación, formatos, licencias |
| `qa-tester` | Plan de pruebas, tests automáticos, reproducir bugs |
| `revisor-codigo` | Revisión de diff: bugs, rendimiento, legibilidad (solo lectura) |
| `optimizador-rendimiento` | Perfilado, presupuestos de frame/memoria |

## Convenciones

- Idioma: documentación y comentarios en **español**; identificadores de código en **inglés**.
- Commits: `tipo(área): descripción` — tipos `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `assets`.
- Ramas: `feature/<slug>`, `fix/<slug>`.
- Lógica de juego separada de presentación (render/audio/input) para poder testearla sin motor.
- Nada de números mágicos en gameplay: los valores de tuning viven en datos (`src/data/` o equivalente).
- Assets: nombres `snake_case`, prefijo por tipo (`spr_`, `sfx_`, `mus_`, `mdl_`, `tex_`). Ver `docs/ASSETS.md`.
- Binarios (`.glb`, `.png`, `.wav`, `.ogg`) → Git LFS.
- GDScript siempre con tipos estáticos; `snake_case` para funciones/variables, `PascalCase` para clases y nodos.
- Física y movimiento en `_physics_process(delta)`, nunca en `_process`.

## Comandos

- `scripts/check.sh` (Linux/Mac/Git Bash) o `scripts/check.ps1` (Windows) — formato, lint, tests de
  reglas y partido de humo IA vs IA. Requiere Godot (`GODOT_BIN`) y `pip install gdtoolkit==4.*`.
- Jugar: abrir `project.godot` en Godot 4.5 y F5. Guía: `docs/PROTOTIPO_1.md`.

## Mapa del código
- `src/logic/` — reglas puras y testeables (choques, aguante, golpeo, posesión, marcador). Sin nodos.
- `src/data/` — `species.json` y `tuning.json`: TODO el tuning. `game_data.gd` los carga y valida.
- `src/game/` — nodos: `match_director` (flujo), `dino` (cuerpo físico), `ball`, `ai_controller`,
  `player_controller`, `broadcast_camera`, `match_hud`, `stadium_builder`, `crowd`, `referee_pterosaur`.
- `src/audio/sfx_synth.gd` — sonidos provisionales sintetizados (sin binarios ni licencias).
- `tests/` — `test_*.gd` (runner propio `run_tests.gd`) y `smoke_match.gd`.

## No hacer

- No inventar requisitos: si la ficha no lo dice, pregunta o anótalo como duda abierta.
- No añadir dependencias/plugins sin registrarlo en un ADR o en `docs/ASSETS.md` (licencias).
- No recrear juegos existentes (nombres, personajes, arte, niveles). El juego es original.
