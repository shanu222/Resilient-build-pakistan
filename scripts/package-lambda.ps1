# Package Lambda for Terraform deploy
$root = Split-Path -Parent $PSScriptRoot
$lambda = Join-Path $root "backend\lambda"
$dist = Join-Path $lambda "dist"
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Path $dist | Out-Null
Copy-Item -Recurse (Join-Path $lambda "src\*") $dist
Set-Location $dist
if (Test-Path "..\dist.zip") { Remove-Item "..\dist.zip" -Force }
Compress-Archive -Path * -DestinationPath "..\dist.zip"
Write-Host "Created backend/lambda/dist.zip"
