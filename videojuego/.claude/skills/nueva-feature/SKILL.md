---
name: nueva-feature
description: Crea la ficha de diseño de una feature nueva del videojuego en docs/design/ a partir de la plantilla, delegando en el agente disenador-juego. Úsala cuando el usuario proponga una mecánica, sistema o contenido nuevo.
argument-hint: <nombre o idea de la feature>
---

Feature solicitada: $ARGUMENTS

1. Genera un slug `kebab-case` para la feature. Si ya existe `docs/design/<slug>.md`, ábrela y actualízala en vez de duplicarla.
2. Lee `docs/GDD.md` (pilares y core loop) y `docs/design/_PLANTILLA_FEATURE.md`.
3. Delega en el agente **disenador-juego** la redacción de `docs/design/<slug>.md` siguiendo la plantilla. Pásale: la idea, los pilares, y que deje las ambigüedades en "Dudas abiertas".
4. Si la feature implica niveles o textos, pide en paralelo aportes a **disenador-niveles** y/o **narrativa**.
5. Pide al **productor** el desglose en tareas y añádelo a la sección "Tareas" de la ficha.
6. Deja el estado de la ficha en `Borrador` y termina con un resumen corto + las dudas abiertas para que el usuario apruebe.
