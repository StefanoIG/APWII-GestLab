# Script para verificar Docker en Windows
Write-Host "🔍 Verificando estado de Docker..." -ForegroundColor Cyan

# Verificar si Docker Desktop está ejecutándose
$dockerProcess = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
if ($dockerProcess) {
    Write-Host "✅ Docker Desktop está ejecutándose (PID: $($dockerProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "❌ Docker Desktop NO está ejecutándose" -ForegroundColor Red
    Write-Host "   Por favor inicia Docker Desktop y espera a que esté listo" -ForegroundColor Yellow
    exit 1
}

# Probar conectividad con Docker
Write-Host "🧪 Probando conectividad con Docker..." -ForegroundColor Cyan
try {
    $dockerVersion = docker version --format "{{.Server.Version}}"
    Write-Host "✅ Docker Engine conectado (Versión: $dockerVersion)" -ForegroundColor Green
} catch {
    Write-Host "❌ No se puede conectar con Docker Engine" -ForegroundColor Red
    Write-Host "   Asegúrate de que Docker Desktop esté completamente iniciado" -ForegroundColor Yellow
    exit 1
}

# Probar Docker Compose
Write-Host "🧪 Probando Docker Compose..." -ForegroundColor Cyan
try {
    $composeVersion = docker compose version --short
    Write-Host "✅ Docker Compose funcionando (Versión: $composeVersion)" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose no responde" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 Docker está listo para usar!" -ForegroundColor Green
Write-Host "Ahora puedes ejecutar: .\scripts\quick-start.ps1" -ForegroundColor Cyan
