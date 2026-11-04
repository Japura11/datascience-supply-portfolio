---
name: revisar-cambios
description: Revisión completa de los cambios actuales del videojuego antes de merge - ejecuta scripts/check.sh, la revisión de código y, si hay riesgo, la de rendimiento. Úsala antes de dar una feature por terminada.
---

1. Ejecuta `scripts/check.sh` desde `videojuego/` y guarda la salida real.
2. Obtén el diff: `git diff main...HEAD -- .` más los cambios sin commitear (`git diff`, `git status`).
3. Identifica la ficha de diseño afectada en `docs/design/`.
4. Lanza en paralelo:
   - **revisor-codigo** con el diff y la ficha.
   - **optimizador-rendimiento** solo si el diff toca bucles de update/process, físicas, render, carga de assets o spawn de entidades.
5. Lanza **qa-tester** para comprobar que cada criterio de aceptación tiene un test o un caso manual documentado.
6. Entrega un único informe:
   ```
   ## Checks: ✅/❌ (salida relevante)
   ## Hallazgos (por severidad, archivo:línea)
   ## Cobertura de criterios de aceptación
   ## Veredicto: listo / cambios necesarios
   ```
No corrijas nada en esta skill; solo informa.
