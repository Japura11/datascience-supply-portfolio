---
name: playtest
description: Estructura las notas de una sesión de playtest en un reporte accionable en docs/playtests/. Úsala cuando el usuario comparta impresiones, notas o grabaciones de alguien jugando.
argument-hint: <notas del playtest o build probada>
---

Notas del playtest: $ARGUMENTS

1. Crea `docs/playtests/AAAA-MM-DD-<slug>.md` usando `docs/playtests/_PLANTILLA_PLAYTEST.md`.
2. Separa **observaciones** (lo que hizo el jugador) de **interpretaciones** (por qué creemos que pasó). No mezcles.
3. Agrupa por tema: controles, comprensión, dificultad, ritmo, bugs, momentos de diversión.
4. Los bugs encontrados pásalos a **qa-tester** para registrarlos en `docs/BUGS.md`.
5. Para problemas de diseño pide a **disenador-juego** / **disenador-niveles** 1–3 hipótesis de ajuste cada uno, sin implementar.
6. Cierra con las 3 acciones prioritarias propuestas para el **productor**.
