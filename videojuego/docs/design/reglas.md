# Reglas del partido (bloque 9)

- **Estado:** Borrador
- **Pilar(es):** 3 — Fútbol con colmillos; 1 — El cuerpo importa

## Partido
- 5 vs 5 (1 portero IA + 4), dos tiempos, **8–10 min** en total.
- **Victoria solo por goles.** Desempate en torneo: _pendiente (prórroga / penaltis / gol de oro)_.

## Aguante
- **Regeneración lenta en campo:** si un dino no recibe golpes durante unos segundos
  (`stamina_regen_delay_s`), recupera aguante poco a poco (`stamina_regen_per_s`).
- La regeneración **no** cura una eliminación: al 0 % el dino sale.
- Por debajo del 50 % → herido (más lento, peor Manejo) hasta volver a superar el umbral.

## Sustituciones
- **Ilimitadas con cooldown** (estilo hockey): cambio voluntario en cualquier momento,
  con `substitution_cooldown_s` por equipo.
- El dino que sale **sigue regenerando** en el banquillo (decisión derivada: premia rotar;
  validar en playtest).
- Las eliminaciones fuerzan sustitución inmediata y **no** consumen cooldown.
- Si el banquillo se agota, el equipo juega con menos.

## Árbitro y faltas
- **Árbitro dino:** un **pterosaurio** que sobrevuela el campo (personaje con animaciones de silbato,
  tarjetas y reacciones; aporta humor e inmersión).
- **Solo pita lo excesivo** (todo lo demás es juego físico legal):
  | Falta | Sanción |
  |---|---|
  | Atacar por la espalda a un rival **sin balón cerca** | Tiro libre |
  | Atacar/eliminar al **portero** dentro de su área | Penalti o tiro libre + tarjeta |
  | Eliminación con habilidad de furia **por la espalda** | Tarjeta amarilla |
  | 2 amarillas | Roja: el dino sale **sin** poder entrar sustituto durante `red_card_penalty_s` |
- El árbitro tiene un campo de visión: lo que no ve, no lo pita (capa de picardía).

## Valores de tuning iniciales (van a datos)
| Parámetro | Valor | Unidad |
|---|---|---|
| match_duration_s | 540 | s |
| stamina_regen_delay_s | 4 | s |
| stamina_regen_per_s | 3 | % aguante/s |
| injured_threshold | 0.5 | fracción |
| substitution_cooldown_s | 20 | s |
| red_card_penalty_s | 60 | s |

## Dudas abiertas
- Desempate en torneo.
- ¿Fuera de juego? (propuesta: no, como en el fútbol sala).
- ¿Saques de banda o campo con paredes/vallas (balón siempre en juego)?
