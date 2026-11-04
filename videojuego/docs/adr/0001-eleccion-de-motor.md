# ADR-0001: Elección de motor y lenguaje

- **Estado:** Propuesto (pendiente de decidir)
- **Fecha:** 2026-11-04

## Contexto
Hay que elegir motor antes de escribir código de gameplay. Depende de:
género (2D/3D), plataforma objetivo, experiencia previa del equipo y licencias.
El portafolio es mayoritariamente Python, lo que pesa en la curva de aprendizaje.

## Opciones consideradas
1. **Godot 4 (GDScript/C#)** — gratis y open source (MIT), ligero, excelente para 2D y bueno en 3D, escenas en texto (diffs legibles en git), GDScript con sintaxis parecida a Python. Contra: ecosistema de assets más pequeño que Unity.
2. **Unity (C#)** — enorme ecosistema y documentación, fuerte en móvil y 3D. Contra: licencia propietaria, proyecto pesado, escenas binarias/YAML más difíciles de revisar.
3. **Pygame / Pygame-CE (Python)** — reutiliza Python directamente, ideal para 2D pequeño y aprender. Contra: sin editor, distribución y rendimiento limitados.
4. **Web (Phaser / TypeScript)** — se juega en el navegador, fácil de compartir en el portafolio. Contra: herramientas de editor más limitadas.

## Decisión
_Pendiente._ Recomendación inicial del `arquitecto-motor`: **Godot 4 con GDScript** si es 2D
o 3D ligero (sintaxis cercana a Python, archivos de texto amigables con git y con agentes);
**Phaser** si la prioridad es que se juegue desde el navegador del portafolio.

## Consecuencias (al aceptar)
- Actualizar `scripts/check.sh` con lint y tests del motor (p. ej. gdlint + GUT en Godot).
- Configurar `.gitattributes` / Git LFS para binarios.
- Actualizar el "Estado actual" de `CLAUDE.md`.
