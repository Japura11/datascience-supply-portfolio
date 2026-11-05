# GDD — Documento de Diseño del Juego

> Fuente de verdad del diseño. Responsable: agente `disenador-juego` + aprobación humana.
> Estado: **En construcción — concepto y formato de partido definidos (bloques 1–5)**
> Título provisional: _por definir_

## 1. Visión en una frase
**Fútbol arcade 3D de dinosaurios** donde los choques de cuerpos con física real, las habilidades
propias de cada especie y una barra de **furia** que permite **eliminar** rivales convierten cada
partido en una mezcla de fútbol y combate táctico con **banquillo**.

Referencias de *género* (no de contenido): simuladores/arcades de fútbol en tercera persona,
juegos de fútbol con físicas y combate, deathmatch por equipos. Todo el contenido es original.

## 2. Pilares de diseño
1. **El cuerpo importa.** Masa, inercia y momentum reales: un choque se siente y cambia la jugada.
   Cada dinosaurio se mueve según su anatomía (gira lento, acelera rápido, cola que golpea…).
2. **Cada especie juega como es.** Las habilidades nacen de la biología del animal
   (embestida del triceratops, mordida del T-Rex), no de poderes arbitrarios.
3. **Fútbol con colmillos.** El objetivo es meter goles, pero la furia, las eliminaciones y la
   gestión del banquillo son una segunda capa de estrategia.
4. **Control con intención.** Pases, recepciones y tiros dependen de la posición, ángulo, curva
   y *timing* del dinosaurio: la habilidad del jugador se nota.

## 3. Público y plataforma
- Género: **deportes arcade 3D / fútbol con físicas y combate**
- Plataformas: **PC (Windows / macOS / Linux)** — Steam / itch.io
- Modelo: **comercial (premium)**
- Cámara: **tercera persona elevada / vista de transmisión** (la más legible en fútbol);
  opción de cámara detrás del jugador. _(a validar en prototipo)_
- Controles: **mando como principal** + teclado/ratón
- Público objetivo: _(bloque 4)_
- Duración de partido: _(bloque 5)_

## 3b. Formato de partido (bloque 4)
- **5 vs 5** dinosaurios en el campo por equipo (estilo fútbol sala), más **banquillo** ("baraja").
- **Modos en la versión publicable:** contra **IA** y **multijugador local** (varios mandos, mismo PC).
  Online: **fuera de alcance** hasta después del lanzamiento.
- **Control:**
  - Un humano contra IA → controla un dinosaurio y **cambia al más cercano al balón** (botón + cambio automático opcional).
  - Multijugador local → cada humano tiene un **dinosaurio fijo**; los huecos los cubre la IA.
- **Eliminación:** el dinosaurio eliminado **sale del partido** y entra uno del banquillo.
  Si el banquillo se agota, el equipo **juega con menos**. La gestión del banquillo es estrategia central.

## 4. Core loop
```
controlar el balón → pasar / chocar / acumular furia → gol o eliminación
       ↑                                                     ↓
   sustituir desde el banquillo  ←  gestionar plantilla y furia
```
- **Segundos:** moverse con inercia, recibir con timing, pasar/tirar con ángulo y curva, chocar.
- **Minutos (partido):** goles, cargas de furia, eliminaciones y sustituciones.
- **Meta (torneo):** elegir la "baraja" de dinosaurios, competir en torneos, desbloquear especies. _(a definir)_

## 5. Mecánicas
| Mecánica | Descripción | Pilar | Ficha |
|---|---|---|---|
| Movimiento físico | Locomoción con masa, aceleración, radio de giro por especie | 1, 2 | _pendiente_ |
| Choques de cuerpos | Colisiones físicas reales; derribo según masa × velocidad | 1 | _pendiente_ |
| Recepción con timing | Ventana de tiempo + input para controlar bien el balón; peor timing = balón suelto | 4 | _pendiente_ |
| Pase / tiro / patada | Fuerza, ángulo y curva según postura y parte del cuerpo (pata, cola, cabeza) | 4, 2 | _pendiente_ |
| Barra de furia | Se carga con acciones (choques, robos, recibir golpes…); habilita la habilidad especial | 3 | _pendiente_ |
| Habilidad de especie | Ej.: Triceratops → embestida imparable que puede eliminar; T-Rex → furia + mordida que elimina al de enfrente | 2, 3 | _pendiente_ |
| Eliminación y banquillo | El dinosaurio eliminado sale; entra uno de la "baraja" del banquillo | 3 | _pendiente_ |
| Clases de tamaño | Límites por tamaño/peso para evitar desbalance (ver §6) | 1, 3 | _pendiente_ |

### Dinosaurios (catálogo inicial a diseñar)
**Objetivo de lanzamiento: 10–12 especies.** ⚠ Es el mayor coste de arte del proyecto.
Mitigación: agrupar por **esqueleto compartido** (bípedo grande, bípedo pequeño, cuadrúpedo, …)
para reutilizar rig y animaciones; la **demo/vertical slice sale con 4–6** y el resto llega en
la fase de contenido.

Dieta como identidad de rol (hipótesis a validar):
- **Carnívoros:** agresivos, furia rápida, habilidades de eliminación (T-Rex, raptor…).
- **Herbívoros:** robustos, buenos en choque y defensa (Triceratops, Ankylosaurus…).
- **Omnívoros:** equilibrados / habilidades de apoyo.

## 6. Balance (bloque 5)
- **Presupuesto por puntos:** cada especie tiene un coste según tamaño y poder. La plantilla
  (5 en campo + banquillo) se arma con un **tope de puntos**. Grande y fuerte = caro = menos banquillo.
- **Portero controlado por IA** (1 de los 5). _Duda: ¿el portero se elige de la plantilla y puede ser eliminado?_
- **Furia** se carga con: **chocar/derribar** rivales, **recibir golpes** (mecánica de remontada) y
  **acciones de fútbol** (robos, pases buenos, recepciones perfectas, goles). Sin carga pasiva por tiempo.
- Toda habilidad que elimina debe tener **contrajuego** (anticipable, esquivable, coste de furia).
- Física "real" pero **afinada para la diversión**: realismo en masa y momentum, arcade en control del balón.

## 7. Mundo y narrativa
Ligera: torneos de dinosaurios en estadios naturales (fantasía/naturaleza). Ver `docs/design/narrativa/BIBLIA.md`.

## 8. Estilo de arte y audio
- **3D low-poly estilizado** hecho en Blender por el propio desarrollador.
- Dinosaurios con siluetas muy distintas y legibles a distancia (clave en un juego de equipo).
- Estadios integrados en la naturaleza: selvas, volcanes, praderas.

## 9. Alcance
Equipo: **1 persona + Claude**. Plazo a versión publicable: **6–12 meses**.
Motor: **Godot 4 / GDScript**, física **Jolt** (ADR-0001).

- **Prototipo 1 (mes 1–2):** 2 cápsulas con masa + balón en un campo gris. ¿Chocar y pasar es divertido?
- **Prototipo 2:** recepción con timing, pase con curva, barra de furia, 1 habilidad.
- **Vertical slice (mes 3–5):** 2 especies con arte final, 1 estadio, partido completo contra IA.
- **Contenido (mes 6–10):** más especies, estadios, modo torneo, banquillo.
- **Lanzamiento (mes 10–12):** pulido, página de Steam, demo.

⚠ Riesgo principal de alcance: **IA de equipo 5 vs 5** (posicionamiento, pases, presión, uso de habilidades).
Mitigación: IA por roles simples (portero/defensa/ataque) y comportamiento basado en utilidad; online descartado para v1.

## 10. Dudas abiertas
- Tamaño del campo y del banquillo (¿cuántas cartas?). ¿Hay sustituciones voluntarias además de las forzadas?
- ¿La entrada desde el banquillo es instantánea o con unos segundos de inferioridad?
- Cámara en multijugador local: ¿pantalla compartida única (recomendado en fútbol) o pantalla dividida?
- Clases de tamaño vs presupuesto por puntos.
- Título del juego.
