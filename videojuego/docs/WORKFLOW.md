# Flujo de trabajo con agentes

Este documento explica **cómo colaboran los agentes** y qué buenas prácticas
siguen. Los agentes son subagentes de Claude Code definidos en
`.claude/agents/`. Cada uno tiene un rol acotado, herramientas mínimas y un
formato de salida fijo.

## Principios del ecosistema

1. **Un rol, una responsabilidad.** Cada agente hace bien una cosa. El que
   diseña no programa; el que revisa no edita.
2. **Mínimo privilegio.** Los agentes de revisión/análisis son de solo lectura
   (`Read`, `Grep`, `Glob`). Solo quien implementa tiene `Edit`/`Write`.
3. **Contexto aislado.** Cada subagente arranca limpio: pásale la ficha, los
   archivos relevantes y el criterio de "hecho". No asumas que "ya sabe".
4. **Artefactos en el repo, no en el chat.** Diseños, decisiones y reportes
   se guardan en `docs/`. El chat es efímero; el repo no.
5. **Humano en el bucle.** Los agentes proponen; las decisiones de diseño y
   los ADRs los aprueba una persona.
6. **Verificación antes de "listo".** Nada se marca terminado sin
   `scripts/check.sh` en verde y una revisión.

## Ciclo de vida de una feature

```
 idea
  │
  ▼
[productor] ── prioriza, define alcance y criterio de "hecho"
  │
  ▼
[disenador-juego] (+ disenador-niveles / narrativa si aplica)
  │   └─ escribe docs/design/<feature>.md  (skill /nueva-feature)
  ▼
 ✋ Aprobación humana de la ficha
  │
  ▼
[arquitecto-motor] ── ¿toca arquitectura? → ADR / plan técnico
  │
  ▼
[qa-tester] ── escribe los casos de prueba desde los criterios de aceptación
  │
  ▼
[programador-gameplay] ── implementa hasta que los tests pasen
  │
  ▼
[revisor-codigo] + [optimizador-rendimiento si hay riesgo]  (skill /revisar-cambios)
  │
  ▼
 playtest (skill /playtest) → docs/playtests/  → ajustes (skill /balance)
  │
  ▼
 merge
```

## Cuándo usar cada agente

| Situación | Agente |
|---|---|
| "¿Qué hacemos ahora?" / partir un hito | `productor` |
| "Quiero una mecánica de X" | `disenador-juego` |
| "Este nivel se siente lento/difícil" | `disenador-niveles` |
| Diálogos, lore, nombres, textos | `narrativa` |
| Elegir motor, estructura, patrón, sistema de guardado | `arquitecto-motor` |
| Implementar algo ya diseñado | `programador-gameplay` |
| Importar sprites/sonidos, nombres, licencias | `pipeline-assets` |
| Bug, plan de pruebas, regresión | `qa-tester` |
| Revisar un diff antes de merge | `revisor-codigo` |
| Caídas de FPS, tirones, memoria | `optimizador-rendimiento` |

## Skills (comandos `/`)

| Skill | Qué hace |
|---|---|
| `/nueva-feature <idea>` | Crea la ficha de diseño desde la plantilla |
| `/revisar-cambios` | Corre checks + revisión de código + rendimiento sobre el diff |
| `/playtest <build/nota>` | Estructura un reporte de playtest |
| `/balance <sistema>` | Analiza y propone ajustes de valores de tuning |

## Cómo invocar

Inicia Claude Code **dentro de `videojuego/`** para que se carguen los agentes,
skills y settings de este proyecto:

```bash
cd videojuego && claude
```

Luego, en lenguaje natural: _"usa el agente disenador-juego para proponer una
mecánica de dash"_, o directamente `/nueva-feature dash`.

## Buenas prácticas al delegar

- Da **objetivo + contexto + criterio de hecho** en el prompt al subagente.
- Paraleliza solo tareas independientes (p. ej. narrativa y niveles de la misma
  feature); serializa las que dependen (diseño → tests → código).
- Pide salidas en el formato del agente; revisa antes de encadenar.
- Si un agente necesita un permiso que no tiene, es señal de que la tarea es de
  otro agente.
