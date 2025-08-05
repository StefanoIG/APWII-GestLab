# Script de configuracion inicial para GestLab Docker en Windows
# Este script prepara el entorno para ejecutar GestLab con Docker
# Version 2.0 - Con deteccion automatica de entorno

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " GestLab Docker - Configuracion Inicial v2.0" -ForegroundColor Yellow
Write-Host " Deteccion Automatica de Entorno" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan

# Verificar que Docker este instalado
Write-Host "[INFO] Verificando Docker..." -ForegroundColor Cyan
try {
    $dockerVersion = docker --version
    Write-Host "[OK] Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker no esta instalado o no esta en el PATH" -ForegroundColor Red
    Write-Host "   Por favor instala Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar que Docker Compose este disponible
Write-Host "[INFO] Verificando Docker Compose..." -ForegroundColor Cyan
try {
    $composeVersion = docker-compose --version
    Write-Host "[OK] Docker Compose encontrado: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker Compose no esta disponible" -ForegroundColor Red
    exit 1
}

# Crear directorio de backup si no existe
$backupDir = "C:\backup"
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force
    Write-Host "[OK] Directorio de backup creado: $backupDir" -ForegroundColor Green
} else {
    Write-Host "[OK] Directorio de backup ya existe: $backupDir" -ForegroundColor Green
}

# Detectar entorno actual
Write-Host "[INFO] Detectando entorno de trabajo..." -ForegroundColor Cyan
$currentEnv = "local"
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "APP_ENV=(\w+)") {
        $currentEnv = $matches[1]
    }
}

Write-Host "[DETECTED] Entorno detectado: $currentEnv" -ForegroundColor Yellow

# Verificar archivos de configuracion
$requiredFiles = @(
    ".env.local",
    ".env.production", 
    "docker-compose.local.yml",
    "docker-compose.production.yml",
    "docker-compose.db.yml"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (!(Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "[WARNING] Archivos de configuracion faltantes:" -ForegroundColor Yellow
    foreach ($file in $missingFiles) {
        Write-Host "   - $file" -ForegroundColor Red
    }
    Write-Host "   Los archivos seran creados automaticamente al ejecutar el gestor" -ForegroundColor Yellow
}

# Configurar archivo .env inicial
if (!(Test-Path ".env")) {
    Write-Host "[INFO] Configurando archivo .env inicial..." -ForegroundColor Cyan
    
    $envTemplate = ".env.$currentEnv"
    if (Test-Path $envTemplate) {
        Copy-Item $envTemplate ".env" -Force
        Write-Host "[OK] Archivo .env configurado para entorno: $currentEnv" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Plantilla $envTemplate no encontrada, usando configuracion basica" -ForegroundColor Yellow
        # Crear .env basico
        $envContent = @"
APP_NAME="GestLab"
APP_ENV=$currentEnv
APP_KEY=base64:EPqmwl4yVdpVwL9f1hob55PnJyUVXcdeeCq8Y853OuM=
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=gestlab-db
DB_PORT=3306
DB_DATABASE=gestlab
DB_USERNAME=gestlab_user
DB_PASSWORD=gestlab_password
"@
        $envContent | Out-File -FilePath ".env" -Encoding UTF8
    }
}

# Verificar red Docker
Write-Host "[INFO] Configurando red Docker..." -ForegroundColor Cyan
$networkExists = docker network ls --format "{{.Name}}" | Select-String -Pattern "^gestlab-network$" -Quiet
if (!$networkExists) {
    docker network create gestlab-network | Out-Null
    Write-Host "[OK] Red gestlab-network creada" -ForegroundColor Green
} else {
    Write-Host "[OK] Red gestlab-network ya existe" -ForegroundColor Green
}

# Crear directorio de SSL si no existe
$sslDir = "docker\nginx\ssl"
if (!(Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir -Force | Out-Null
    Write-Host "[OK] Directorio SSL creado: $sslDir" -ForegroundColor Green
}

# Para PowerShell, verificar politica de ejecucion
Write-Host "[INFO] Verificando permisos de PowerShell..." -ForegroundColor Cyan
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "[WARNING] La politica de ejecucion esta restringida" -ForegroundColor Yellow
    Write-Host "   Ejecuta: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Politica de ejecucion configurada correctamente" -ForegroundColor Green
}

Write-Host ""
Write-Host "[SUCCESS] Configuracion completada!" -ForegroundColor Green

Write-Host ""
Write-Host "PROXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "   1. Ejecuta: .\scripts\gestlab-smart.ps1 build" -ForegroundColor White
Write-Host "   2. Espera a que se construyan los contenedores" -ForegroundColor White
Write-Host "   3. El sistema detectara automaticamente el entorno (local/production)" -ForegroundColor White
Write-Host "   4. Accede segun el entorno configurado" -ForegroundColor White

Write-Host ""
Write-Host "ENLACES SEGUN ENTORNO:" -ForegroundColor Cyan
Write-Host "   Local (HTTP):" -ForegroundColor Yellow
Write-Host "     - Aplicacion: http://localhost:8000" -ForegroundColor Gray
Write-Host "     - phpMyAdmin: http://localhost:8080" -ForegroundColor Gray
Write-Host "   Produccion (HTTPS):" -ForegroundColor Yellow
Write-Host "     - Aplicacion: https://localhost:8443" -ForegroundColor Gray
Write-Host "     - phpMyAdmin: http://localhost:8080" -ForegroundColor Gray
Write-Host "   Comun:" -ForegroundColor Yellow
Write-Host "     - Base de Datos: localhost:3307" -ForegroundColor Gray
Write-Host "     - Backups: $backupDir" -ForegroundColor Gray

Write-Host ""
Write-Host "COMANDOS DISPONIBLES:" -ForegroundColor Cyan
Write-Host "   .\scripts\gestlab-smart.ps1 build        # Construir todo" -ForegroundColor Gray
Write-Host "   .\scripts\gestlab-smart.ps1 start        # Iniciar contenedores" -ForegroundColor Gray
Write-Host "   .\scripts\gestlab-smart.ps1 stop         # Detener contenedores" -ForegroundColor Gray
Write-Host "   .\scripts\gestlab-smart.ps1 switch-env   # Cambiar local/production" -ForegroundColor Gray
Write-Host "   .\scripts\gestlab-smart.ps1 status       # Ver estado" -ForegroundColor Gray
Write-Host "   .\scripts\gestlab-smart.ps1 logs         # Ver logs" -ForegroundColor Gray
Write-Host "   .\scripts\gestlab-smart.ps1 clean        # Limpiar todo" -ForegroundColor Gray

Write-Host ""
Write-Host "CAMBIO DE ENTORNO:" -ForegroundColor Cyan
Write-Host "   - El sistema detecta automaticamente desde .env" -ForegroundColor Gray
Write-Host "   - Usa 'switch-env' para cambiar entre local y production" -ForegroundColor Gray
Write-Host "   - Local: HTTP en puerto 8000" -ForegroundColor Gray
Write-Host "   - Production: HTTPS en puerto 8443 + SSL automatico" -ForegroundColor Gray

Write-Host ""
Write-Host "CONFIGURACION SSL:" -ForegroundColor Cyan
Write-Host "   - En modo 'production' se generan certificados SSL automaticamente" -ForegroundColor Gray
Write-Host "   - Los certificados se almacenan en: docker\nginx\ssl\" -ForegroundColor Gray
Write-Host "   - HTTPS forzado con redireccion automatica desde HTTP" -ForegroundColor Gray

Write-Host ""
Write-Host "ENTORNO ACTUAL DETECTADO: $currentEnv" -ForegroundColor Green
