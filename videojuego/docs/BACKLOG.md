# Backlog

> Responsable: agente `productor`. Prioridad MoSCoW. Detalle de diseño en `docs/GDD.md`.

## Hito 0: Pre-producción
- [x] Ecosistema de agentes y flujo de trabajo
- [x] Visión, pilares, formato de partido, balance y modos (GDD bloques 1–6)
- [x] Decidir motor (ADR-0001 → Godot 4 + Jolt)
- [x] Catálogo candidato de 16 especies + sistema de habilidades/letalidad/combos (docs/design/dinosaurios.md)
- [ ] Elegir las 10–12 especies del lanzamiento
- [x] Controles y cámara (bloque 7 → docs/design/controles.md)
- [x] Reglas finas: aguante, sustituciones, árbitro (bloque 9)
- [x] Proyecto base Godot 4.5 + `scripts/check.sh` / `check.ps1` en verde
- [x] Ficha del Prototipo 1 (`docs/design/prototipo-1.md`)

## Hito 1: Prototipo 1 — "¿chocar y pasar es divertido?"
- [x] Campo plano con líneas, paredes, porterías, gradas con público y paisaje
- [x] 4 "dinos de bloques" (T-Rex, Velociraptor, Triceratops, Pachycephalosaurus) con masa e inercia
- [x] Choques con daño/derribo según masa × velocidad, embestida, ragdoll, aguante
- [x] Pata / cola / cabeza con potencia, curva y precisión
- [x] Posesión y robo; IA simple 2 vs 2
- [x] Game feel: hit-stop, temblor, polvo, sonido sintetizado, público reactivo, árbitro pterosaurio
- [x] ADR-0002: RigidBody3D controlado por velocidad + ragdoll de cuerpo entero
- [ ] **Playtest humano** (`/playtest`) y ajustes (`/balance`)

## Hito 2: Prototipo 2 — control con intención y furia
- [ ] Recepción con ventana de timing
- [ ] Faltas del árbitro pterosaurio
- [ ] Pase/tiro con ángulo y curva
- [ ] Barra de furia + 1 habilidad (embestida)
- [ ] Eliminación + entrada desde banquillo
- [ ] IA básica por roles + portero IA

## Hito 3: Vertical slice
- [ ] 8 especies de la demo con arte low-poly final (4 esqueletos compartidos)
- [ ] 1 combo de pareja (Trampolín de cráneo)
- [ ] 1 estadio final, audio y feedback
- [ ] Partido rápido 5v5 completo vs IA y local

## Must
- Partido 5v5 vs IA y local, furia, eliminación/banquillo, presupuesto por puntos, portero IA.
## Should
- Torneo, desbloqueo de especies, 10–12 especies.
## Could
- Liga/carrera completa, DLC.
## Won't (v1)
- Multijugador online, microtransacciones.
