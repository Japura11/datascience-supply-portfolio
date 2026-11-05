# Backlog

> Responsable: agente `productor`. Prioridad MoSCoW. Detalle de diseño en `docs/GDD.md`.

## Hito 0: Pre-producción
- [x] Ecosistema de agentes y flujo de trabajo
- [x] Visión, pilares, formato de partido, balance y modos (GDD bloques 1–6)
- [x] Decidir motor (ADR-0001 → Godot 4 + Jolt)
- [ ] Catálogo de especies: 10–12 con dieta, tamaño, coste en puntos y habilidad
- [x] Controles y cámara (bloque 7 → docs/design/controles.md)
- [ ] Instalar Godot 4, GUT y gdtoolkit; proyecto base + `scripts/check.sh` en verde
- [ ] Ficha: movimiento físico de dinosaurio (primera mecánica)

## Hito 1: Prototipo 1 — "¿chocar y pasar es divertido?"
- [ ] Campo gris, porterías, balón físico
- [ ] 2 "dinosaurios cápsula" con masa, inercia y radio de giro distintos
- [ ] Choques con derribo según masa × velocidad
- [ ] Pase y tiro básicos
- [ ] ADR-0002: RigidBody3D vs CharacterBody3D + impulsos

## Hito 2: Prototipo 2 — control con intención y furia
- [ ] Recepción con ventana de timing
- [ ] Pase/tiro con ángulo y curva
- [ ] Barra de furia + 1 habilidad (embestida)
- [ ] Eliminación + entrada desde banquillo
- [ ] IA básica por roles + portero IA

## Hito 3: Vertical slice
- [ ] 4–6 especies con arte low-poly final (esqueletos compartidos)
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
