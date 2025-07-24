# Script para configurar la estructura de 3 contenedores separados
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   GestLab - Configuracion de 3 Contenedores   " -ForegroundColor Yellow
Write-Host "     Laravel App + Nginx + MySQL separados     " -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "Creando estructura de directorios..." -ForegroundColor Yellow

# Crear directorio para la base de datos en C:
$dbDir = "C:\gestlab-db"
$backupDir = "C:\backup"

if (!(Test-Path $dbDir)) {
    New-Item -ItemType Directory -Path $dbDir -Force | Out-Null
    New-Item -ItemType Directory -Path "$dbDir\data" -Force | Out-Null
    New-Item -ItemType Directory -Path "$dbDir\docker" -Force | Out-Null
    Write-Host "Directorio de BD creado: $dbDir" -ForegroundColor Green
}

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Host "Directorio de backup creado: $backupDir" -ForegroundColor Green
}

# Copiar archivos necesarios para la BD
Write-Host "Copiando archivos de configuracion..." -ForegroundColor Yellow

Copy-Item "docker-compose.db.yml" "$dbDir\docker-compose.yml" -Force
Copy-Item "docker\init-db.sh" "$dbDir\docker\" -Force
Copy-Item "docker\backup-db.sh" "$dbDir\docker\backup.sh" -Force

Write-Host "Archivos copiados a $dbDir" -ForegroundColor Green

# Crear red Docker compartida
Write-Host "Creando red Docker compartida..." -ForegroundColor Yellow
try {
    docker network create gestlab-network 2>$null
    Write-Host "Red 'gestlab-network' creada" -ForegroundColor Green
} catch {
    Write-Host "Red 'gestlab-network' ya existe" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Estructura creada exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "Directorios creados:" -ForegroundColor Cyan
Write-Host "  C:\gestlab-db\                    # Base de datos independiente" -ForegroundColor Gray
Write-Host "  C:\gestlab-db\data\               # Datos de MySQL" -ForegroundColor Gray
Write-Host "  C:\gestlab-db\docker\             # Scripts de BD" -ForegroundColor Gray
Write-Host "  C:\backup\                        # Backups automaticos" -ForegroundColor Gray
Write-Host ""
Write-Host "Archivos principales:" -ForegroundColor Cyan
Write-Host "  C:\gestlab-db\docker-compose.yml  # Compose para BD" -ForegroundColor Gray
Write-Host "  docker\Dockerfile.nginx           # Dockerfile para Nginx" -ForegroundColor Gray
Write-Host "  docker\nginx.conf                 # Configuracion Nginx" -ForegroundColor Gray
Write-Host "  docker\default.conf               # Virtual host Laravel" -ForegroundColor Gray
Write-Host "  docker\app-entrypoint.sh          # Inicializacion Laravel" -ForegroundColor Gray
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Iniciar BD:  .\scripts\gestlab-3containers.ps1 start-db" -ForegroundColor White
Write-Host "  2. Iniciar App: .\scripts\gestlab-3containers.ps1 start-app" -ForegroundColor White
Write-Host "  3. O todo:      .\scripts\gestlab-3containers.ps1 start" -ForegroundColor White
Write-Host "  4. Acceder:     http://localhost:8000" -ForegroundColor White
Write-Host ""
Write-Host "Configuracion completada!" -ForegroundColor Green
