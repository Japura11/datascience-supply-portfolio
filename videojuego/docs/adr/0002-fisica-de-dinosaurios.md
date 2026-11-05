# ADR-0002: Física de los dinosaurios y del balón

- **Estado:** Aceptado (prototipo 1)
- **Fecha:** 2026-11-05

## Contexto
El pilar 1 exige choques con masa real. Opciones en Godot: `CharacterBody3D` (movimiento
cinemático, choques "simulados" a mano) o `RigidBody3D` (el motor resuelve el intercambio de
momento). También hay que decidir cómo se hace el derribo tipo ragdoll con poco coste.

## Opciones consideradas
1. **CharacterBody3D + impulsos manuales** — control muy preciso; pero los choques entre dinos
   no transfieren momento de forma natural y habría que programar toda la física de contacto.
2. **RigidBody3D controlado por velocidad** — el motor (Jolt) resuelve los choques con masa
   real; el control se hace en `_integrate_forces` limitando la aceleración por especie.
3. **Ragdoll con esqueleto (PhysicalBone3D)** — derribo realista, pero caro de montar y de
   afinar antes de tener modelos finales.

## Decisión
- Dinos = **RigidBody3D** con rotación X/Z bloqueada mientras están de pie. El control fija la
  velocidad deseada con aceleración máxima por especie (`accel`), giro limitado (`turn_rate_deg`)
  y `forward_bias` (los grandes se mueven sobre todo hacia donde miran).
- **Derribo = "ragdoll de cuerpo entero":** se desbloquea la rotación, se aplica impulso y giro,
  el cuerpo rueda con física y luego se endereza. Ragdoll por huesos: cuando haya modelos finales.
- El daño del choque lo calcula cada dino con la velocidad **previa** del rival hacia él
  (`ImpactRules`, lógica pura y testeada), no con el impulso de contacto del motor.
- Balón = RigidBody3D con CCD, efecto por fuerza de Magnus y conducción suave al poseedor.
- Motor físico: **Jolt** (`project.godot`).

## Consecuencias
- Choques creíbles casi gratis; el tuning vive en `src/data/species.json` y `tuning.json`.
- El control nunca es 100 % exacto (el motor puede desviar al dino): es intencionado (pilar 1).
- En P1 el mundo se construye por código (sin escenas `.tscn` complejas) para iterar rápido;
  al entrar arte final se pasará a escenas editables en el editor.
