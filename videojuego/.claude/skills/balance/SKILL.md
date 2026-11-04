---
name: balance
description: Analiza los valores de tuning de un sistema del juego (daño, vida, velocidades, cooldowns, economía, drop rates) y propone ajustes justificados. Úsala cuando algo se sienta demasiado fácil, difícil, lento o roto.
argument-hint: <sistema a balancear>
---

Sistema: $ARGUMENTS

1. Localiza los datos de tuning del sistema (`src/data/` o equivalente) y la ficha de diseño. Si los valores están hardcodeados en código, repórtalo como primer hallazgo.
2. Con **disenador-juego**, explicita la intención: ¿qué debe sentir el jugador? (p. ej. "matar un enemigo básico: 2–3 golpes").
3. Calcula las métricas derivadas relevantes (TTK, DPS, tiempo para cruzar la pantalla, ingreso/gasto por minuto). Usa un script en Python si ayuda; muestra la tabla.
4. Propón cambios con formato `parámetro: actual → propuesto (motivo, efecto esperado)`. Cambios pequeños (±10–25 %) y de una variable a la vez cuando sea posible.
5. Indica qué observar en el próximo playtest para validar.
No apliques los cambios salvo que el usuario lo pida.
