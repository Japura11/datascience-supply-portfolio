# Dinosaurios: sistema de habilidades, letalidad y catálogo (bloque 8)

- **Estado:** Borrador (valores ilustrativos, se ajustan con `/balance` y playtests)
- **Pilar(es):** 2 — Cada especie juega como es; 3 — Fútbol con colmillos

## 1. Kit de cada especie
Cada dinosaurio tiene:
1. **Atributos de campo (1–5)** en las 5 categorías de habilidad:
   | Categoría | Qué mide |
   |---|---|
   | **Ataque** | Daño y derribo contra otros dinosaurios |
   | **Robo** | Facilidad para quitar el balón |
   | **Defensa** | Resistencia a choques, bloqueo de pases/tiros |
   | **Manejo** | Control, regate, recepción (ventana de timing más amplia) |
   | **Remate** | Potencia y precisión de tiro / cabezazo |
2. **Rasgo pasivo** que sale de su anatomía (cuernos, cola maza, cresta, plumas…).
3. **Habilidad de campo** (sin furia, con cooldown) en una de las 5 categorías.
4. **Habilidad de furia** (barra llena): la jugada espectacular de la especie.
5. **Combo de pareja** opcional con ciertos compañeros (ver §3).

## 2. Aguante, heridas y letalidad
El tamaño **no elimina por sí solo**, pero sí define **quién puede ser letal con quién**.

- **Aguante:** cada dino tiene una barra de aguante (más alta cuanto más grande).
- Los golpes restan aguante según **masa × velocidad × Ataque** del atacante.
- Por debajo del 50 % → **herido**: más lento, peor Manejo. Al 0 % → **fuera de combate** (eliminado → entra banquillo).
- **Letalidad (L0–L3):** solo las especies letales tienen ataques que **eliminan de golpe**, y solo
  contra rivales de su **tamaño o menor**:
  | Nivel | Puede eliminar de golpe a… | Ejemplos |
  |---|---|---|
  | L0 | Nadie (solo desgasta) | Gallimimus, Oviraptor |
  | L1 | Pequeños | Velociraptor, Dilophosaurus |
  | L2 | Pequeños y medianos | Carnotaurus, Triceratops |
  | L3 | Todos | T-Rex, Giganotosaurus |
- Un raptor **no derriba a un gigante de un golpe**, pero sí **lo desgasta**: varios ataques
  de pequeños pueden dejar a un grande herido y luego fuera de combate. Equipos de "manada" vs "tanques".
- Toda eliminación de golpe tiene **contrajuego**: animación de aviso legible, esquivable, coste total de furia.
- Las especies letales cuestan más puntos.

## 3. Combos de pareja (jugadas épicas)
Dos compañeros cerca + input coordinado (o automático si el compañero es IA) → jugada especial.
| Combo | Quién | Qué pasa |
|---|---|---|
| **Trampolín de cráneo** | Pachycephalosaurus + cualquier dino grande/mediano | El "cabeza de huevo" corre, salta sobre el lomo del compañero y remata de cabeza en el aire: cabezazo épico |
| **Catapulta de cola** | Ankylosaurus/Stegosaurus + pequeño | El grande lanza al pequeño con la cola hacia el área |
| **Manada** | 2+ Velociraptor | El segundo raptor hereda el derribo del primero: el robo en cadena es casi seguro |
| **Cuello-grúa** | Brachiosaurus juvenil + pequeño | Levanta al compañero para interceptar un pase alto |

Reglas: cuestan furia **compartida** (mitad cada uno), tienen cooldown y animación de preparación visible.

## 4. Catálogo candidato (16 → elegir 10–12 para el lanzamiento)
Coste orientativo con tope de **100 pts** por plantilla (campo + banquillo).
Atributos: Ata/Rob/Def/Man/Rem.

| Esqueleto | Especie | Tam. | L | Pts | Ata/Rob/Def/Man/Rem | Rasgo pasivo | Hab. de campo | Hab. de furia |
|---|---|---|---|---|---|---|---|---|
| Bípedo G | **T-Rex** ⭐ | G | 3 | 26 | 5/2/4/1/4 | Rugido: rivales cercanos pierden timing | Empujón de pecho (Ata) | **Mordida**: se come al de enfrente |
| Bípedo G | **Giganotosaurus** | G | 3 | 27 | 5/3/3/1/3 | Más rápido que el T-Rex, menos aguante | Carga larga (Ata) | **Frenesí**: 2 mordidas seguidas |
| Bípedo G | **Spinosaurus** | G | 2 | 22 | 4/3/4/2/3 | Vela dorsal: bloquea pases altos | Coletazo giratorio (Def) | **Zarpazo de río**: atrapa el balón en el aire |
| Bípedo M | **Carnotaurus** | M | 2 | 18 | 4/2/2/3/4 | Cuernos: derribo mayor en carrera | Topetazo (Ata) | **Sprint de toro**: carrera imparable con balón |
| Bípedo M | **Baryonyx** | M | 1 | 14 | 3/4/2/3/2 | Garra pescadora: recepciones fáciles | Garfio (Rob) | **Arpón**: arrebata el balón a distancia |
| Bípedo M | **Therizinosaurus** | M | 1 | 15 | 3/5/3/2/2 | Garras de 1 m: alcance de robo enorme | Barrido de garras (Rob) | **Tijera**: roba y derriba a todos en cono |
| Bípedo P | **Velociraptor** ⭐ | P | 1 | 11 | 3/4/1/4/2 | Manada: bonus junto a otro raptor | Salto con garra (Rob) | **Emboscada**: desaparece y reaparece tras el rival |
| Bípedo P | **Dilophosaurus** | P | 1 | 11 | 2/3/2/3/2 | Collar: intimida al portador | Escupitajo: ralentiza (Ata) | **Ceguera**: el rival pierde su cámara/indicadores |
| Bípedo P | **Oviraptor** ⭐ | P | 0 | 9 | 1/5/1/4/2 | Ladrón de huevos: robos sin falta | Robo limpio (Rob) | **Atraco**: roba y pasa al primer toque |
| Bípedo P | **Gallimimus** ⭐ | P | 0 | 8 | 1/2/1/5/3 | El más rápido del juego | Regate en zigzag (Man) | **Turbo**: sprint infinito unos segundos |
| Bípedo P | **Microraptor** | P | 0 | 9 | 1/3/1/4/3 | Planea: saltos largos | Vuelo corto (Man) | **Picado**: remate en vuelo desde el aire |
| Bípedo M | **Pachycephalosaurus** ⭐ | M | 1 | 14 | 3/2/2/3/5 | Cráneo de huevo: cabezazos ×2 | Cabezazo-ariete (Rem) | **Meteorito**: salto altísimo + cabezazo imparable |
| Bípedo M | **Parasaurolophus** | M | 0 | 12 | 1/2/3/3/3 | Cresta-trompeta | Llamada: compañeros cargan furia (apoyo) | **Onda sónica**: aturde en área |
| Cuadrúpedo G | **Triceratops** ⭐ | G | 2 | 22 | 5/2/5/1/2 | Gola: frontal casi inmune | Corneada (Ata) | **Embestida imparable**: elimina en línea recta |
| Cuadrúpedo M | **Ankylosaurus** ⭐ | M | 1 | 18 | 3/2/5/1/4 | Armadura: mucho aguante | Maza de cola: despeje/tiro (Rem) | **Terremoto**: golpe al suelo que derriba alrededor |
| Cuadrúpedo M | **Stegosaurus** ⭐ | M | 1 | 16 | 2/2/5/2/2 | Placas: bloquea tiros por los lados | Muro de placas (Def) | **Thagomizer**: coletazo que aturde y despeja |
| Cuadrúpedo G | **Brachiosaurus juvenil** | G | 0 | 20 | 1/3/4/2/2 | Cuello largo: intercepción alta | Barrera de cuello (Def) | **Cuello-látigo**: pase largo a cualquier punto |

⭐ = las **8 especies de la demo / vertical slice** elegidas por el usuario.

### Esqueletos compartidos (para reutilizar rig y animación)
- **Bípedo grande:** T-Rex, Giganotosaurus, Spinosaurus
- **Bípedo mediano:** Carnotaurus, Baryonyx, Therizinosaurus, Pachycephalosaurus, Parasaurolophus
- **Bípedo pequeño:** Velociraptor, Dilophosaurus, Oviraptor, Gallimimus, Microraptor
- **Cuadrúpedo:** Triceratops, Ankylosaurus, Stegosaurus (+ variante de cuello largo para el Brachiosaurus)

La demo usa **4 esqueletos** → 8 especies sin animar 8 veces desde cero.

## 5. Dudas abiertas
- ¿El aguante se recupera durante el partido (en el descanso, lentamente, en el banquillo)?
- ¿Un dino herido puede salir voluntariamente al banquillo para salvarse?
- ¿Los combos de pareja se descubren jugando o se explican en un tutorial?
- Licencia creativa: los diseños son estilizados y caricaturescos, no reconstrucciones científicas.
