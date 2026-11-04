# 🎮 Videojuego — proyecto en pre-producción

Proyecto de videojuego original dentro del portafolio. Esta primera entrega
monta el **ecosistema de agentes de Claude Code** que apoya el desarrollo;
el juego en sí arranca tras decidir el motor
([ADR-0001](docs/adr/0001-eleccion-de-motor.md)).

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
├── src/  assets/  tests/
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
