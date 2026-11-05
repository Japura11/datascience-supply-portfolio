# 🦖⚽ Dino Fútbol — fútbol arcade 3D de dinosaurios

Juego original: fútbol 5 vs 5 con dinosaurios, choques con física real, habilidades por especie,
furia, eliminaciones y banquillo. Motor **Godot 4.5** ([ADR-0001](docs/adr/0001-eleccion-de-motor.md)).

**Estado:** Prototipo 1 jugable (2 vs 2 en campo plano). Cómo jugarlo: [docs/PROTOTIPO_1.md](docs/PROTOTIPO_1.md).
Diseño: [GDD](docs/GDD.md) · [dinosaurios](docs/design/dinosaurios.md) · [controles](docs/design/controles.md) · [reglas](docs/design/reglas.md).

## Estructura
```
videojuego/
├── CLAUDE.md                 ← memoria y convenciones del proyecto para Claude
├── .claude/
│   ├── settings.json         ← permisos del proyecto
│   ├── agents/               ← 10 subagentes especializados
│   └── skills/               ← /nueva-feature, /revisar-cambios, /playtest, /balance
├── docs/
│   ├── WORKFLOW.md           ← cómo colaboran los agentes
│   ├── GDD.md                ← documento de diseño (plantilla)
│   ├── BACKLOG.md  BUGS.md  ASSETS.md
│   ├── adr/                  ← decisiones de arquitectura
│   ├── design/               ← fichas de feature, niveles, narrativa
│   └── playtests/            ← reportes de playtest
├── scripts/check.sh          ← lint + tests (punto único para agentes y CI)
├── project.godot             ← proyecto Godot (F5 para jugar)
├── src/logic/                ← reglas puras testeables
├── src/data/                 ← species.json + tuning.json (todo el tuning)
├── src/game/  src/audio/     ← nodos del juego y sonido sintetizado
├── tests/                    ← tests de reglas + partido de humo IA vs IA
```

## Empezar
```bash
cd videojuego && claude
```
Primeros pasos sugeridos:
1. _"Usa el disenador-juego para completar la visión y los pilares del GDD con esta idea: …"_
2. _"Usa el arquitecto-motor para cerrar el ADR-0001"_
3. `/nueva-feature <primera mecánica>`

Detalle del flujo en [docs/WORKFLOW.md](docs/WORKFLOW.md).
