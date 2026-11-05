# Controles y cámara (bloque 7)

- **Estado:** Borrador (mapeo propuesto, a validar en prototipo 2)
- **Pilar(es):** 4 — Control con intención; 2 — Cada especie juega como es

## Cámara
| Cámara | Uso | Notas |
|---|---|---|
| Transmisión lateral elevada | Por defecto; **obligatoria** en multijugador local (pantalla compartida) | Encuadra balón + jugadores relevantes; zoom dinámico según dispersión |
| Detrás del jugador | Opcional en partidas con un solo humano | Sigue al dino controlado; cambia con él al cambiar de jugador |

## Recepción con timing
Pulsar **Recibir** (o cualquier botón de toque) dentro de la ventana en que llega el balón:
- **Perfecta** (ventana estrecha) → control limpio + **furia**.
- **Buena** → control normal.
- **Fuera de ventana / sin pulsar** → el balón rebota (balón suelto).
- El tamaño de la ventana depende de la especie (pequeños = más ágiles) y de la velocidad del balón.
- Indicador visual sutil (anillo que se cierra) desactivable en opciones.

## Pase y tiro por parte del cuerpo
Cada botón usa una parte del cuerpo con trayectorias propias. **Mantener = potencia**,
**stick izquierdo al soltar = dirección**, **stick derecho al soltar = curva/efecto**.

| Parte | Botón (mando) | Trayectoria | Notas por especie |
|---|---|---|---|
| **Pata** | A / ✕ | Pase raso preciso; tiro colocado | Base para todos |
| **Cola** | X / ▢ | Pase largo/barrido con mucha curva; despeje | Mejor en especies de cola larga/maza |
| **Cabeza** | Y / △ | Pase elevado / cabezazo / tiro potente | Mejor en especies con cráneo/cuernos |

## Mapeo propuesto (7 acciones + movimiento)
| Acción | Mando | Teclado/ratón | Sin balón |
|---|---|---|---|
| Moverse | Stick izq. | WASD | — |
| Curva / efecto | Stick der. | Ratón | — |
| Pata | A / ✕ | Clic izq. / J | Recibir (timing) |
| Cola | X / ▢ | Clic der. / K | Barrido de cola (entrada) |
| Cabeza | Y / △ | L | Cabezazo aéreo / despeje |
| Choque / embestida | B / ○ | Espacio | Cargar contra el rival |
| Habilidad de especie (furia llena) | RB / R1 | E | Igual |
| Sprint | RT / R2 | Shift | Igual (consume estamina) |
| Cambiar jugador (solo vs IA) | LB / L1 | Q | Igual |

## Criterios de aceptación (para prototipo 2)
- [ ] Un jugador nuevo da un pase raso a un compañero en < 2 min de práctica.
- [ ] Recepción perfecta vs mala se distingue claramente (visual + sonoro).
- [ ] Pata, cola y cabeza producen trayectorias claramente distintas y predecibles.
- [ ] Ningún botón tiene más de 2 funciones según contexto.

## Dudas abiertas
- ¿Finta/regate como acción propia o combinación (sprint + soltar)?
- ¿Remapeo completo de controles en opciones? (recomendado para PC)
- Pase al hueco vs pase al pie: ¿lo decide la potencia o un modificador?
