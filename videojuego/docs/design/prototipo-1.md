# Feature: Prototipo 1 — "¿chocar y pasar es divertido?"

- **Estado:** Implementada (pendiente de playtest humano)
- **Pilar(es):** 1 — El cuerpo importa · 4 — Control con intención
- **Prioridad (MoSCoW):** Must

## Objetivo
Validar en un campo plano, con arte provisional, que **moverse con masa, chocar y golpear el
balón** se siente bien antes de invertir en arte, furia, banquillo o IA seria.

## Qué incluye
| Elemento | Estado en P1 |
|---|---|
| Partido 2 vs 2 (tú + IA vs IA) | ✅ T-Rex + Velociraptor (azul) vs Triceratops + Pachycephalosaurus (rojo) — editable en `src/data/tuning.json` → `teams` |
| Movimiento con masa e inercia | ✅ aceleración, velocidad, radio de giro y "sesgo hacia delante" por especie |
| Choques físicos | ✅ daño y derribo según masa × velocidad × Ataque/Defensa; embestida (Espacio) |
| Derribo con ragdoll | ✅ el dino cae, rueda con física y se levanta |
| Aguante | ✅ barra sobre la cabeza; herido < 50 % (más lento); regeneración lenta; a 0 → fuera 5 s |
| Pata / cola / cabeza | ✅ trayectorias distintas; mantener = potencia; A/D al soltar = curva |
| Precisión | ✅ más potencia = menos precisión; el Remate la mejora |
| Posesión y robo | ✅ control según Manejo; robo progresivo según Robo vs Manejo |
| Game feel | ✅ hit-stop, temblor de cámara, polvo, sonido sintetizado, público que bota y ruge |
| Cámaras | ✅ transmisión y detrás del jugador (C) |
| Árbitro pterosaurio | 🟡 vuela y pita saques/goles; **faltas no** (prototipo posterior) |

## Fuera de alcance (llega en Prototipo 2+)
Recepción con ventana de timing, furia y habilidades de especie, banquillo real (ahora el
eliminado vuelve a los 5 s), portero, faltas, combos de pareja, 5 vs 5, multijugador local.

## Criterios de aceptación
- [x] Se puede jugar un partido completo de 5 min contra la IA sin errores.
- [x] Un T-Rex y un Velociraptor se sienten distintos al moverse (giro, aceleración, puntería).
- [x] Un raptor no derriba a un T-Rex de un golpe, pero sí lo desgasta (test automático).
- [x] Pata, cola y cabeza producen trayectorias distintas (tests automáticos).
- [x] Pulsar A/D al soltar curva el balón hacia ese lado (test automático).
- [ ] **Playtest humano:** responde las preguntas de abajo.

## Preguntas del playtest (para `/playtest`)
1. Al chocar con el T-Rex, ¿se siente el peso? ¿Y con el raptor?
2. ¿El giro lento de los grandes es divertido o frustrante?
3. ¿Se entiende cuándo tienes el balón y cuándo te lo roban?
4. ¿Pata / cola / cabeza se distinguen? ¿Alguna sobra?
5. ¿La embestida (Espacio) es demasiado fuerte o débil?
6. ¿Qué cámara prefieres?
7. Del 1 al 10: ¿cuánto te apetece jugar otro partido?

## Métricas de referencia (partido IA vs IA de 5 min, semilla fija)
~3 goles · ~16 golpeos · ~105 choques · ~25 derribos · ~4 fuera de combate · ~56 cambios de posesión.
Si un cambio de tuning las mueve mucho, revísalo con `/balance`.
