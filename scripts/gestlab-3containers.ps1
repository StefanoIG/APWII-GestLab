# Script para gestionar los 3 contenedores de GestLab por separado
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "build", "logs", "status", "clean", "start-db", "stop-db", "start-app", "stop-app")]
    [string]$Command
)

$ProjectDir = "C:\projects\APWII-GestLab"
$DbDir = "C:\gestlab-db"

function Write-Header {
    param([string]$Message)
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
}

function Invoke-DockerCompose {
    param([string]$Directory, [string]$Arguments)
    
    $currentDir = Get-Location
    try {
        Set-Location $Directory
        Invoke-Expression "docker compose $Arguments"
    } finally {
        Set-Location $currentDir
    }
}

switch ($Command) {
    "start" {
        Write-Header "Iniciando todos los contenedores de GestLab"
        
        # Crear red si no existe
        try {
            docker network create gestlab-network 2>$null
        } catch {
            Write-Host "Red gestlab-network ya existe" -ForegroundColor Gray
        }
        
        # Iniciar base de datos primero
        Write-Host "Iniciando base de datos..." -ForegroundColor Cyan
        Invoke-DockerCompose $DbDir "up -d"
        
        # Esperar un poco para que la BD este lista
        Start-Sleep -Seconds 5
        
        # Iniciar aplicacion y nginx
        Write-Host "Iniciando aplicacion y Nginx..." -ForegroundColor Cyan
        Invoke-DockerCompose $ProjectDir "up -d"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Todos los contenedores iniciados!" -ForegroundColor Green
            Write-Host "Aplicacion: http://localhost:8000" -ForegroundColor Cyan
            Write-Host "phpMyAdmin: http://localhost:8080" -ForegroundColor Cyan
            Write-Host "MySQL: localhost:3307" -ForegroundColor Cyan
        }
    }
    
    "stop" {
        Write-Header "Deteniendo todos los contenedores"
        Write-Host "Deteniendo aplicacion..." -ForegroundColor Yellow
        Invoke-DockerCompose $ProjectDir "down"
        
        Write-Host "Deteniendo base de datos..." -ForegroundColor Yellow
        Invoke-DockerCompose $DbDir "down"
        
        Write-Host "Todos los contenedores detenidos!" -ForegroundColor Green
    }
    
    "restart" {
        Write-Header "Reiniciando todos los contenedores"
        & $PSCommandPath -Command "stop"
        Start-Sleep -Seconds 2
        & $PSCommandPath -Command "start"
    }
    
    "build" {
        Write-Header "Construyendo e iniciando contenedores"
        
        # Crear red si no existe
        try {
            docker network create gestlab-network 2>$null
        } catch {}
        
        # Construir e iniciar BD
        Write-Host "Construyendo base de datos..." -ForegroundColor Cyan
        Invoke-DockerCompose $DbDir "up -d --build"
        
        Start-Sleep -Seconds 5
        
        # Construir e iniciar aplicacion
        Write-Host "Construyendo aplicacion..." -ForegroundColor Cyan
        Invoke-DockerCompose $ProjectDir "build --no-cache"
        Invoke-DockerCompose $ProjectDir "up -d"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Construccion completada!" -ForegroundColor Green
        }
    }
    
    "logs" {
        Write-Header "Logs de todos los contenedores"
        Write-Host "Logs de aplicacion:" -ForegroundColor Cyan
        Invoke-DockerCompose $ProjectDir "logs --tail=50"
        
        Write-Host "`nLogs de base de datos:" -ForegroundColor Cyan
        Invoke-DockerCompose $DbDir "logs --tail=50"
    }
    
    "status" {
        Write-Header "Estado de todos los contenedores"
        Write-Host "Estado de aplicacion:" -ForegroundColor Cyan
        Invoke-DockerCompose $ProjectDir "ps"
        
        Write-Host "`nEstado de base de datos:" -ForegroundColor Cyan
        Invoke-DockerCompose $DbDir "ps"
        
        Write-Host "`nUso de recursos:" -ForegroundColor Cyan
        docker stats --no-stream
    }
    
    "clean" {
        Write-Header "Limpieza completa"
        Write-Host "ADVERTENCIA: Esto eliminara todos los datos!" -ForegroundColor Red
        $confirm = Read-Host "Estas seguro? (y/N)"
        
        if ($confirm -eq "y" -or $confirm -eq "Y") {
            Invoke-DockerCompose $ProjectDir "down -v"
            Invoke-DockerCompose $DbDir "down -v"
            docker system prune -f
            Write-Host "Limpieza completada!" -ForegroundColor Green
        } else {
            Write-Host "Operacion cancelada" -ForegroundColor Yellow
        }
    }
    
    "start-db" {
        Write-Header "Iniciando solo base de datos"
        try {
            docker network create gestlab-network 2>$null
        } catch {}
        Invoke-DockerCompose $DbDir "up -d"
        Write-Host "Base de datos iniciada!" -ForegroundColor Green
    }
    
    "stop-db" {
        Write-Header "Deteniendo base de datos"
        Invoke-DockerCompose $DbDir "down"
        Write-Host "Base de datos detenida!" -ForegroundColor Green
    }
    
    "start-app" {
        Write-Header "Iniciando solo aplicacion"
        Invoke-DockerCompose $ProjectDir "up -d"
        Write-Host "Aplicacion iniciada!" -ForegroundColor Green
    }
    
    "stop-app" {
        Write-Header "Deteniendo aplicacion"
        Invoke-DockerCompose $ProjectDir "down"
        Write-Host "Aplicacion detenida!" -ForegroundColor Green
    }
}

Write-Host "`nComandos disponibles:" -ForegroundColor Cyan
Write-Host "   start      - Iniciar todos los contenedores" -ForegroundColor Gray
Write-Host "   stop       - Detener todos los contenedores" -ForegroundColor Gray
Write-Host "   restart    - Reiniciar todos los contenedores" -ForegroundColor Gray
Write-Host "   build      - Construir e iniciar todo" -ForegroundColor Gray
Write-Host "   logs       - Ver logs de todos los contenedores" -ForegroundColor Gray
Write-Host "   status     - Ver estado de todos los contenedores" -ForegroundColor Gray
Write-Host "   clean      - Limpiar todo (elimina datos)" -ForegroundColor Gray
Write-Host "   start-db   - Iniciar solo base de datos" -ForegroundColor Gray
Write-Host "   stop-db    - Detener solo base de datos" -ForegroundColor Gray
Write-Host "   start-app  - Iniciar solo aplicacion" -ForegroundColor Gray
Write-Host "   stop-app   - Detener solo aplicacion" -ForegroundColor Gray
