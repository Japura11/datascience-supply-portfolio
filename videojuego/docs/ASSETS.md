# Assets: convenciones y licencias

> Responsable: agente `pipeline-assets`.

## Estructura
```
assets/
├── art/      (sprites, texturas, modelos)  — exportados
├── audio/    (sfx, música)
├── fonts/
├── ui/
└── _source/  (archivos editables: .aseprite, .blend, .psd)
```

## Nombres
`snake_case` + prefijo: `spr_`, `tex_`, `mdl_`, `sfx_`, `mus_`, `fnt_`, `ui_`.
Ejemplo: `spr_player_run_01.png`, `sfx_jump_02.wav`.

## Formatos y presupuestos (ajustar al elegir motor)
| Tipo | Formato | Presupuesto |
|---|---|---|
| Sprites | PNG | potencia de 2 en atlas, ≤ 2048² |
| SFX | WAV (fuente) / OGG (juego) | ≤ 3 s, 44,1 kHz |
| Música | OGG | ≤ 5 MB por pista |

## Registro de licencias
| Asset | Autor | Origen (URL) | Licencia | Atribución requerida |
|---|---|---|---|---|

Reglas: sin licencia clara no entra; nada extraído de juegos u obras existentes.
