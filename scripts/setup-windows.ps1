# Script de configuración inicial para GestLab Docker en Windows
# Este script prepara el entorno para ejecutar GestLab con Docker

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " GestLab Docker - Configuración Inicial" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

# Verificar que Docker esté instalado
Write-Host "🔍 Verificando Docker..." -ForegroundColor Cyan
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "   Por favor instala Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar que Docker Compose esté disponible
Write-Host "🔍 Verificando Docker Compose..." -ForegroundColor Cyan
try {
    $composeVersion = docker-compose --version
    Write-Host "✅ Docker Compose encontrado: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose no está disponible" -ForegroundColor Red
    exit 1
}

# Crear directorio de backup si no existe
$backupDir = "C:\backup"
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force
    Write-Host "✅ Directorio de backup creado: $backupDir" -ForegroundColor Green
} else {
    Write-Host "✅ Directorio de backup ya existe: $backupDir" -ForegroundColor Green
}

# Copiar archivo .env para Docker
if (!(Test-Path ".env.docker")) {
    Write-Host "❌ Archivo .env.docker no encontrado" -ForegroundColor Red
    exit 1
}

Copy-Item ".env.docker" ".env" -Force
Write-Host "✅ Archivo .env configurado para Docker" -ForegroundColor Green

# Dar permisos de ejecución a los scripts
Write-Host "🔧 Configurando permisos de scripts..." -ForegroundColor Cyan

# Para PowerShell, verificar política de ejecución
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "⚠️  La política de ejecución está restringida" -ForegroundColor Yellow
    Write-Host "   Ejecuta: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
}

Write-Host "`n🚀 Configuración completada!" -ForegroundColor Green
Write-Host "`n📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "   1. Ejecuta: .\scripts\gestlab-docker.ps1 build" -ForegroundColor White
Write-Host "   2. Espera a que se construyan los contenedores" -ForegroundColor White
Write-Host "   3. Accede a: http://localhost:8000" -ForegroundColor White
Write-Host "   4. phpMyAdmin: http://localhost:8080" -ForegroundColor White

Write-Host "`n🔗 Enlaces útiles:" -ForegroundColor Cyan
Write-Host "   Aplicación: http://localhost:8000" -ForegroundColor Gray
Write-Host "   phpMyAdmin: http://localhost:8080" -ForegroundColor Gray
Write-Host "   Backups: $backupDir" -ForegroundColor Gray

Write-Host "`n💡 Ayuda:" -ForegroundColor Cyan
Write-Host "   .\scripts\gestlab-docker.ps1 -Command help" -ForegroundColor Gray
