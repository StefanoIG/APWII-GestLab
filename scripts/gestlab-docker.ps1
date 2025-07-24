# Script PowerShell para gestionar GestLab Docker en Windows
# Uso: .\gestlab-docker.ps1 [comando]
# Comandos: start, stop, restart, build, logs, backup, restore, clean

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "build", "logs", "backup", "restore", "clean", "status")]
    [string]$Command,
    
    [string]$BackupFile = ""
)

$ProjectName = "gestlab"
$BackupDir = "C:\backup"

function Invoke-DockerCompose {
    param([string]$Arguments)
    
    try {
        Invoke-Expression "docker compose $Arguments"
    } catch {
        try {
            Invoke-Expression "docker-compose $Arguments"
        } catch {
            Write-Host "❌ Error ejecutando Docker Compose" -ForegroundColor Red
            throw
        }
    }
}

function Write-Header {
    param([string]$Message)
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
}

function Ensure-BackupDirectory {
    if (!(Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force
        Write-Host "Directorio de backup creado: $BackupDir" -ForegroundColor Green
    }
}

switch ($Command) {
    "start" {
        Write-Header "Iniciando GestLab Docker"
        Ensure-BackupDirectory
        Invoke-DockerCompose "up -d"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ GestLab iniciado exitosamente!" -ForegroundColor Green
            Write-Host "🌐 Aplicación: http://localhost:8000" -ForegroundColor Cyan
            Write-Host "🗄️  phpMyAdmin: http://localhost:8080" -ForegroundColor Cyan
        }
    }
    
    "stop" {
        Write-Header "Deteniendo GestLab Docker"
        Invoke-DockerCompose "down"
        Write-Host "✅ GestLab detenido exitosamente!" -ForegroundColor Green
    }
    
    "restart" {
        Write-Header "Reiniciando GestLab Docker"
        Invoke-DockerCompose "down"
        Ensure-BackupDirectory
        Invoke-DockerCompose "up -d"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ GestLab reiniciado exitosamente!" -ForegroundColor Green
        }
    }
    
    "build" {
        Write-Header "Construyendo GestLab Docker"
        Ensure-BackupDirectory
        Invoke-DockerCompose "build --no-cache"
        Invoke-DockerCompose "up -d"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ GestLab construido e iniciado exitosamente!" -ForegroundColor Green
        }
    }
    
    "logs" {
        Write-Header "Mostrando logs de GestLab"
        Invoke-DockerCompose "logs -f"
    }
    
    "backup" {
        Write-Header "Creando backup manual"
        Ensure-BackupDirectory
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "$BackupDir\gestlab_manual_backup_$timestamp.sql"
        
        Invoke-DockerCompose "exec db mysqldump -u gestlab_user -pgestlab_password gestlab" | Out-File -FilePath $backupFile -Encoding UTF8
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Backup creado: $backupFile" -ForegroundColor Green
        } else {
            Write-Host "❌ Error al crear backup" -ForegroundColor Red
        }
    }
    
    "restore" {
        if ($BackupFile -eq "") {
            Write-Host "❌ Por favor especifica el archivo de backup:" -ForegroundColor Red
            Write-Host "   .\gestlab-docker.ps1 restore -BackupFile 'C:\backup\archivo.sql'" -ForegroundColor Yellow
            return
        }
        
        if (!(Test-Path $BackupFile)) {
            Write-Host "❌ Archivo de backup no encontrado: $BackupFile" -ForegroundColor Red
            return
        }
        
        Write-Header "Restaurando backup desde $BackupFile"
        Get-Content $BackupFile | Invoke-DockerCompose "exec -T db mysql -u gestlab_user -pgestlab_password gestlab"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Backup restaurado exitosamente!" -ForegroundColor Green
        } else {
            Write-Host "❌ Error al restaurar backup" -ForegroundColor Red
        }
    }
    
    "clean" {
        Write-Header "Limpiando GestLab Docker"
        Invoke-DockerCompose "down -v"
        docker system prune -f
        Write-Host "✅ Limpieza completada!" -ForegroundColor Green
    }
    
    "status" {
        Write-Header "Estado de GestLab Docker"
        Invoke-DockerCompose "ps"
        Write-Host "`n📊 Uso de recursos:" -ForegroundColor Cyan
        docker stats --no-stream
    }
}

Write-Host "`n💡 Comandos disponibles:" -ForegroundColor Cyan
Write-Host "   start    - Iniciar contenedores" -ForegroundColor Gray
Write-Host "   stop     - Detener contenedores" -ForegroundColor Gray
Write-Host "   restart  - Reiniciar contenedores" -ForegroundColor Gray
Write-Host "   build    - Construir e iniciar" -ForegroundColor Gray
Write-Host "   logs     - Ver logs en tiempo real" -ForegroundColor Gray
Write-Host "   backup   - Crear backup manual" -ForegroundColor Gray
Write-Host "   restore  - Restaurar desde backup" -ForegroundColor Gray
Write-Host "   clean    - Limpiar todo" -ForegroundColor Gray
Write-Host "   status   - Ver estado y recursos" -ForegroundColor Gray
