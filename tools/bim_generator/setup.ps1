# Resilient Build Pakistan — BIM generator toolchain setup (Windows)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$repo = Split-Path -Parent $root

Write-Host "=== BIM Generator Setup ===" -ForegroundColor Cyan

# Python deps
python -m pip install --upgrade pip
python -m pip install -r (Join-Path $PSScriptRoot "requirements.txt")

# Optional: Blender (manual if choco unavailable)
if (Get-Command choco -ErrorAction SilentlyContinue) {
  if (-not (Get-Command blender -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Blender via Chocolatey (optional, large download)..."
    choco install blender -y --ignore-checksums 2>$null
  }
}

# FFmpeg
if (Get-Command choco -ErrorAction SilentlyContinue) {
  if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    choco install ffmpeg -y 2>$null
  }
}

# Node preview tools
$preview = Join-Path $PSScriptRoot "preview"
if (Test-Path (Join-Path $preview "package.json")) {
  Push-Location $preview
  npm install
  Pop-Location
}

Write-Host "Setup complete. Generate assets:" -ForegroundColor Green
Write-Host "  python tools/bim_generator/generate_all.py"
