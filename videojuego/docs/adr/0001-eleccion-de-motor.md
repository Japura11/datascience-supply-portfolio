# ADR-0001: Elección de motor y lenguaje

- **Estado:** Aceptado
- **Fecha:** 2026-11-05

## Contexto
Hay que elegir motor antes de escribir código de gameplay. Depende de:
género (2D/3D), plataforma objetivo, experiencia previa del equipo y licencias.
El portafolio es mayoritariamente Python, lo que pesa en la curva de aprendizaje.

Datos confirmados (bloques 1–2):
- Género: **fútbol arcade 3D de dinosaurios con físicas de choque** (revisado; inicialmente plataformas 3D).
- Plataforma: **PC** (Windows/Mac/Linux). Objetivo **comercial**.
- Equipo: **una persona + Claude**, sin experiencia previa en motores (Python/data).
- Plazo a primera versión publicable: **6–12 meses**.

## Opciones consideradas
1. **Godot 4 (GDScript/C#)** — gratis y open source (MIT), ligero, excelente para 2D y bueno en 3D, escenas en texto (diffs legibles en git), GDScript con sintaxis parecida a Python. Contra: ecosistema de assets más pequeño que Unity.
2. **Unity (C#)** — enorme ecosistema y documentación, fuerte en móvil y 3D. Contra: licencia propietaria, proyecto pesado, escenas binarias/YAML más difíciles de revisar.
3. **Pygame / Pygame-CE (Python)** — reutiliza Python directamente, ideal para 2D pequeño y aprender. Contra: sin editor, distribución y rendimiento limitados.
4. **Web (Phaser / TypeScript)** — se juega en el navegador, fácil de compartir en el portafolio. Contra: herramientas de editor más limitadas.

## Decisión
**Godot 4.x (rama estable) con GDScript tipado.**

Motivos:
- GDScript tiene sintaxis cercana a Python → curva mínima para un dev solo sin experiencia en motores.
- Licencia MIT: sin royalties ni cuotas, adecuado para venta comercial.
- Escenas y recursos en texto (`.tscn`, `.tres`): diffs legibles y editables por los agentes.
- Exporta a Windows/macOS/Linux; publicable en Steam (GodotSteam) e itch.io.
- Un 3D estilizado (low-poly / toon) está bien cubierto y es el alcance de arte realista para una persona.

Descartados: Unreal (curva y peso excesivos para un dev solo novato), Unity (viable, pero licencia
propietaria y C# añade curva), Pygame/Phaser (no adecuados para 3D comercial en PC).

## Consecuencias
- Estilo visual **estilizado**, no fotorrealista (se fija en el GDD).
- GDScript con **tipado estático** obligatorio (`var speed: float`) para errores tempranos y autocompletado.
- Tests con un **runner mínimo propio** (`tests/run_tests.gd`, sin dependencias) + test de humo
  IA vs IA (`tests/smoke_match.gd`). GUT se puede adoptar más adelante si hace falta.
- Lint/format con **gdtoolkit** (`gdlint`, `gdformat`).
- `scripts/check.sh` (y `check.ps1` en Windows) ejecuta formato, lint, tests y partido de humo.
- Git LFS para binarios (`.glb`, `.png`, `.wav`, `.ogg`) vía `.gitattributes`.
- Física con **Jolt** (integrado en Godot 4.4+): mejor rendimiento y estabilidad en colisiones de cuerpos.
- Dinosaurios como `RigidBody3D` o `CharacterBody3D` + impulsos: **decisión en ADR-0002** tras el prototipo 1.
- La decisión de motor sigue siendo válida con el cambio de género: Godot cubre física 3D, IA y exportación a PC.
- Riesgo: menos tutoriales 3D que Unity → mitigación: prototipos pequeños y referencias oficiales de Godot.
