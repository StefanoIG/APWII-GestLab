# GestLab - Script de gestion de contenedores Docker con deteccion automatica de entorno
# Version: 2.0

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "build", "logs", "status", "clean", "start-db", "stop-db", "start-app", "stop-app", "switch-env", "help")]
    [string]$Command = "help"
)

# Funcion para detectar entorno automaticamente
function Get-Environment {
    # Detectar desde .env si existe
    if (Test-Path ".env") {
        $envContent = Get-Content ".env" -Raw
        if ($envContent -match "APP_ENV=(\w+)") {
            $detectedEnv = $matches[1]
            Write-Host "[DETECTED] Entorno detectado desde .env: $detectedEnv" -ForegroundColor Cyan
            return $detectedEnv
        }
    }
    
    # Por defecto usar local
    Write-Host "[WARNING] No se pudo detectar entorno, usando: local" -ForegroundColor Yellow
    return "local"
}

# Funcion para configurar entorno
function Set-Environment {
    param([string]$env)
    
    Write-Host "[CONFIG] Configurando entorno: $env" -ForegroundColor Cyan
    
    # Copiar archivo .env correspondiente
    $envFile = ".env.$env"
    if (Test-Path $envFile) {
        Copy-Item $envFile ".env" -Force
        Write-Host "[OK] Archivo .env configurado para $env" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Archivo $envFile no encontrado, usando .env existente" -ForegroundColor Yellow
    }
    
    # Determinar archivos docker-compose
    $dbComposeFile = "docker-compose.db.yml"
    $appComposeFile = "docker-compose.$env.yml"
    
    if (!(Test-Path $appComposeFile)) {
        $appComposeFile = "docker-compose.yml"
        Write-Host "[WARNING] Usando docker-compose.yml por defecto" -ForegroundColor Yellow
    }
    
    return @{
        DbComposeFile = $dbComposeFile
        AppComposeFile = $appComposeFile
        Environment = $env
    }
}

# Funcion para mostrar puertos segun entorno
function Show-Ports {
    param([string]$env)
    
    if ($env -eq "production") {
        Write-Host "URLS DE ACCESO (Produccion):" -ForegroundColor Cyan
        Write-Host "   - Aplicacion HTTPS: https://localhost:8443" -ForegroundColor Green
        Write-Host "   - Redireccion HTTP: http://localhost:8000 -> HTTPS" -ForegroundColor Yellow
        Write-Host "   - phpMyAdmin: http://localhost:8080" -ForegroundColor Green
        Write-Host "   - Base de datos: localhost:3307" -ForegroundColor Gray
    } else {
        Write-Host "URLS DE ACCESO (Local):" -ForegroundColor Cyan
        Write-Host "   - Aplicacion HTTP: http://localhost:8000" -ForegroundColor Green
        Write-Host "   - phpMyAdmin: http://localhost:8080" -ForegroundColor Green
        Write-Host "   - Base de datos: localhost:3307" -ForegroundColor Gray
    }
}

# Detectar entorno actual
$currentEnv = Get-Environment
$config = Set-Environment -env $currentEnv

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " GestLab Docker Manager - Entorno: $($config.Environment.ToUpper())" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

switch ($Command) {
    "switch-env" {
        Write-Host "Cambio de entorno" -ForegroundColor Cyan
        Write-Host "Entorno actual: $currentEnv" -ForegroundColor White
        
        if ($currentEnv -eq "production") {
            $newEnv = "local"
        } else {
            $newEnv = "production"
        }
        
        Write-Host "Cambiando a: $newEnv" -ForegroundColor Yellow
        $config = Set-Environment -env $newEnv
        Write-Host "[OK] Entorno cambiado a $newEnv" -ForegroundColor Green
        Write-Host "[INFO] Ejecuta 'restart' para aplicar cambios" -ForegroundColor Yellow
        Show-Ports -env $newEnv
    }
    
    "build" {
        Write-Host "Construyendo e iniciando contenedores" -ForegroundColor Cyan
        Write-Host "Construyendo base de datos..." -ForegroundColor White
        docker-compose -f $config.DbComposeFile up -d
        
        Write-Host "Construyendo aplicacion..." -ForegroundColor White
        docker-compose -f $config.AppComposeFile build --no-cache
        docker-compose -f $config.AppComposeFile up -d
        
        Write-Host "Construccion completada!" -ForegroundColor Green
        Show-Ports -env $config.Environment
    }
    
    "start" {
        Write-Host "Iniciando todos los contenedores" -ForegroundColor Cyan
        docker-compose -f $config.DbComposeFile up -d
        docker-compose -f $config.AppComposeFile up -d
        Write-Host "Todos los contenedores iniciados!" -ForegroundColor Green
        Show-Ports -env $config.Environment
    }
    
    "stop" {
        Write-Host "Deteniendo todos los contenedores" -ForegroundColor Cyan
        docker-compose -f $config.AppComposeFile down
        docker-compose -f $config.DbComposeFile down
        Write-Host "Todos los contenedores detenidos!" -ForegroundColor Green
    }
    
    "status" {
        Write-Host "Estado de todos los contenedores" -ForegroundColor Cyan
        Write-Host "Estado de aplicacion:" -ForegroundColor White
        docker-compose -f $config.AppComposeFile ps
        Write-Host "Estado de base de datos:" -ForegroundColor White
        docker-compose -f $config.DbComposeFile ps
        Write-Host "Uso de recursos:" -ForegroundColor White
        docker stats --no-stream
        Show-Ports -env $config.Environment
    }
    
    "help" {
        Write-Host "GestLab - Gestion de Contenedores Docker" -ForegroundColor Cyan
        Write-Host "Entorno actual: $($config.Environment)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Uso: .\gestlab-smart.ps1 [COMANDO]" -ForegroundColor White
        Write-Host ""
        Write-Host "Comandos disponibles:" -ForegroundColor Cyan
        Write-Host "   build        - Construir e iniciar todo" -ForegroundColor White
        Write-Host "   start        - Iniciar todos los contenedores" -ForegroundColor White
        Write-Host "   stop         - Detener todos los contenedores" -ForegroundColor White
        Write-Host "   status       - Ver estado y recursos" -ForegroundColor White
        Write-Host "   switch-env   - Cambiar entre local/production" -ForegroundColor Yellow
        Write-Host "   start-db     - Solo base de datos" -ForegroundColor White
        Write-Host "   stop-db      - Solo base de datos" -ForegroundColor White
        Write-Host "   start-app    - Solo aplicacion" -ForegroundColor White
        Write-Host "   stop-app     - Solo aplicacion" -ForegroundColor White
        Write-Host ""
        Show-Ports -env $config.Environment
    }
    
    default {
        Write-Host "GestLab - Gestion de Contenedores Docker" -ForegroundColor Cyan
        Write-Host "Entorno actual: $($config.Environment)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Uso: .\gestlab-smart.ps1 [COMANDO]" -ForegroundColor White
        Write-Host ""
        Write-Host "Comandos disponibles:" -ForegroundColor Cyan
        Write-Host "   build        - Construir e iniciar todo" -ForegroundColor White
        Write-Host "   start        - Iniciar todos los contenedores" -ForegroundColor White
        Write-Host "   stop         - Detener todos los contenedores" -ForegroundColor White
        Write-Host "   status       - Ver estado y recursos" -ForegroundColor White
        Write-Host "   switch-env   - Cambiar entre local/production" -ForegroundColor Yellow
        Write-Host ""
        Show-Ports -env $config.Environment
    }
}
