# Cómo jugar el Prototipo 1 (Windows)

## 1. Instalar Godot
1. Descarga **Godot 4.5.1 (Standard, no .NET)** para Windows desde https://godotengine.org/download/windows/
2. Descomprime el `.zip` en, por ejemplo, `C:\Godot\`. No requiere instalación.

## 2. Abrir y jugar
1. Ejecuta `Godot_v4.5.1-stable_win64.exe`.
2. **Importar** → selecciona `videojuego\project.godot` de este repositorio → *Importar y editar*.
3. Pulsa **F5** (o el botón ▶ arriba a la derecha) para jugar.

## Controles (teclado y ratón)
| Acción | Tecla |
|---|---|
| Moverse | **W A S D** |
| Sprint | **Shift** |
| Pata (pase raso / tiro) | **J** o **clic izquierdo** |
| Cola (pase largo con curva) | **K** o **clic derecho** |
| Cabeza (pase alto / cabezazo) | **L** o **clic central** |
| Embestida | **Espacio** |
| Cambiar de dino | **Q** |
| Cambiar cámara | **C** |
| Reiniciar partido | **R** |

- **Mantén** el botón de golpeo para cargar potencia (barra "Carga del golpe").
- Al **soltar**, mantener **A** o **D** curva el balón hacia ese lado.
- Más potencia = menos precisión. Los grandes apuntan casi solo hacia donde miran.

## 3. Cambiar valores sin programar
Todo el tuning está en `videojuego/src/data/`:
- `species.json` — masa, velocidad, giro, aguante y atributos de cada especie.
- `tuning.json` — daño de choques, potencia de golpeos, duración del partido, equipos del 2 vs 2.

Edita, guarda y vuelve a pulsar F5. Para ajustes razonados usa `/balance <sistema>` con Claude.

## 4. Verificar (opcional, para desarrollo)
En PowerShell, desde `videojuego\`:
```powershell
pip install "gdtoolkit==4.*"
$env:GODOT_BIN = "C:\Godot\Godot_v4.5.1-stable_win64_console.exe"
.\scripts\check.ps1
```

## 5. Después de jugar
Cuéntale a Claude tus impresiones con `/playtest <tus notas>`; las preguntas guía están en
`docs/design/prototipo-1.md`.
