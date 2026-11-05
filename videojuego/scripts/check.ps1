# Verificación en Windows (PowerShell): formato + lint + tests + partido de humo.
# Uso:  $env:GODOT_BIN = "C:\Godot\Godot_v4.5.1-stable_win64_console.exe"; .\scripts\check.ps1
$ErrorActionPreference = "Continue"
Set-Location (Join-Path $PSScriptRoot "..")
$fail = $false
$godot = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { "godot" }

Write-Host "`n> Formato y lint (gdtoolkit)"
if (Get-Command gdformat -ErrorAction SilentlyContinue) {
    gdformat --check src/ tests/; if ($LASTEXITCODE -ne 0) { $fail = $true }
    gdlint src/ tests/;           if ($LASTEXITCODE -ne 0) { $fail = $true }
} else { Write-Host "! gdtoolkit no instalado: pip install gdtoolkit==4.*" }

function Invoke-Godot([string[]]$GodotArgs) {
    $out = & $godot --headless --path . @GodotArgs 2>&1 | Out-String
    Write-Host $out
    return ($LASTEXITCODE -eq 0) -and ($out -notmatch "SCRIPT ERROR|Parse Error")
}

Write-Host "`n> Importar proyecto"
& $godot --headless --path . --import *> $null

Write-Host "`n> Tests de reglas"
if (-not (Invoke-Godot @("-s", "res://tests/run_tests.gd"))) { $fail = $true }

Write-Host "`n> Partido de humo IA vs IA"
if (-not (Invoke-Godot @("--fixed-fps", "60", "-s", "res://tests/smoke_match.gd"))) { $fail = $true }

if ($fail) { Write-Host "`nX check.ps1: hay fallos"; exit 1 } else { Write-Host "`nOK check.ps1: todo en verde" }
