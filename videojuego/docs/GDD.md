# GDD — Documento de Diseño del Juego

> Fuente de verdad del diseño. Responsable: agente `disenador-juego` + aprobación humana.
> Estado: **En construcción — bloques 1–2 completados**

## 1. Visión en una frase
_<Género> donde el jugador <verbo principal> para <objetivo>, con el giro de <diferenciador>._

## 2. Pilares de diseño (3 máximo)
1. _Pilar 1 — qué debe sentir el jugador_
2. _Pilar 2_
3. _Pilar 3_

Toda feature debe reforzar al menos un pilar. Si no, va a "Won't".

## 3. Público y plataforma
- Género: **plataformas / acción 3D**
- Público objetivo: _(bloque pendiente)_
- Plataformas: **PC (Windows / macOS / Linux)** — Steam / itch.io
- Modelo: **comercial (premium)**
- Controles: _(bloque pendiente; en 3D se recomienda mando como principal + teclado/ratón)_
- Duración de sesión típica: _(bloque pendiente)_

## 4. Core loop
```
<acción> → <recompensa> → <progresión> → <acción más difícil/interesante>
```
- Loop de segundos:
- Loop de minutos:
- Loop de horas/meta:

## 5. Mecánicas
| Mecánica | Verbo | Pilar | Ficha |
|---|---|---|---|
| | | | `docs/design/...` |

## 6. Progresión y dificultad

## 7. Mundo y narrativa
Ver `docs/design/narrativa/BIBLIA.md`.

## 8. Estilo de arte y audio
Referencias de *estilo* (no assets): paleta, resolución, tono musical.

## 9. Alcance
Equipo: **1 persona + Claude**. Plazo a versión publicable: **6–12 meses**.
Motor: **Godot 4 / GDScript** (ADR-0001). Estilo visual: **3D estilizado** (no fotorrealista).

- **Prototipo (mes 1–2):** personaje en caja gris con movimiento y cámara que se sienten bien.
- **Vertical slice (mes 3–4):** 1 nivel completo con calidad final de arte, audio y feedback.
- **Contenido (mes 5–10):** resto de niveles reutilizando el kit del vertical slice.
- **Lanzamiento (mes 10–12):** pulido, página de Steam, demo, marketing.

## 10. Dudas abiertas
