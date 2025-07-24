# GestLab Docker - Inicio Rápido
# Ejecuta este script para configurar e iniciar GestLab por primera vez

Write-Host @"
╔══════════════════════════════════════════╗
║            🚀 GestLab Docker             ║
║         Inicio Rápido - Windows          ║
╚══════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "📋 Verificando requisitos..." -ForegroundColor Yellow

# Verificar Docker
try {
    $null = docker --version
    Write-Host "✅ Docker: OK" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está instalado" -ForegroundColor Red
    Write-Host "   Descarga Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar Docker Compose
try {
    $null = docker compose version
    Write-Host "✅ Docker Compose: OK" -ForegroundColor Green
} catch {
    try {
        $null = docker-compose --version
        Write-Host "✅ Docker Compose (legacy): OK" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker Compose no disponible" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n🔧 Configurando entorno..." -ForegroundColor Yellow

# Crear directorio de backup
$backupDir = "C:\backup"
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Host "✅ Directorio de backup creado: $backupDir" -ForegroundColor Green
}

# Configurar .env para Docker
if (Test-Path ".env.docker") {
    Copy-Item ".env.docker" ".env" -Force
    Write-Host "✅ Configuración Docker aplicada" -ForegroundColor Green
}

Write-Host "`n🏗️  Construyendo contenedores..." -ForegroundColor Yellow
Write-Host "   (Esto puede tomar varios minutos la primera vez)" -ForegroundColor Gray

# Construir e iniciar
try {
    docker compose build --no-cache
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al construir contenedores" -ForegroundColor Red
        exit 1
    }
} catch {
    # Intentar con docker-compose legacy
    docker-compose build --no-cache
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al construir contenedores" -ForegroundColor Red
        exit 1
    }
}

try {
    docker compose up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al iniciar contenedores" -ForegroundColor Red
        exit 1
    }
} catch {
    # Intentar con docker-compose legacy
    docker-compose up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al iniciar contenedores" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n⏳ Esperando que los servicios estén listos..." -ForegroundColor Yellow

# Esperar que la aplicación esté lista
$maxAttempts = 30
$attempt = 0
do {
    $attempt++
    Start-Sleep -Seconds 2
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            break
        }
    } catch {
        # Continúa intentando
    }
    
    if ($attempt -ge $maxAttempts) {
        Write-Host "⚠️  La aplicación está tardando en iniciar. Verifica los logs." -ForegroundColor Yellow
        break
    }
} while ($true)

Write-Host @"

🎉 ¡GestLab está listo!

📍 URLs de acceso:
   🌐 Aplicación:  http://localhost:8000
   🗄️  phpMyAdmin: http://localhost:8080

📊 Estado de servicios:
"@ -ForegroundColor Green

try {
    docker compose ps
} catch {
    docker-compose ps
}

Write-Host @"

💡 Comandos útiles:
   Ver logs:     .\scripts\gestlab-docker.ps1 logs
   Detener:      .\scripts\gestlab-docker.ps1 stop
   Reiniciar:    .\scripts\gestlab-docker.ps1 restart
   Backup:       .\scripts\gestlab-docker.ps1 backup
   Estado:       .\scripts\gestlab-docker.ps1 status

📁 Backups automáticos en: C:\backup

¡Disfruta usando GestLab! 🚀
"@ -ForegroundColor Cyan
