# Script de inicializacion automatica para Foro Academico en Windows
# Este script configura completamente el entorno Docker y prepara la aplicacion

param(
    [switch]$Force,
    [switch]$SkipBuild,
    [switch]$Clean,
    [string]$Environment = "local"
)

# Funcion para mostrar mensajes con colores
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}
 
function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Progress {
    param([string]$Message)
    Write-Host "[PROGRESS] $Message" -ForegroundColor Magenta
}

# Funcion para verificar si un contenedor esta saludable
function Wait-ForContainer {
    param(
        [string]$ContainerName,
        [int]$MaxAttempts = 30,
        [int]$SleepSeconds = 10
    )
    
    Write-Progress "Esperando a que el contenedor '$ContainerName' este listo..."
    
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            $status = docker-compose ps -q $ContainerName | ForEach-Object { docker inspect $_ --format '{{.State.Health.Status}}' 2>$null }
            if ($status -eq "healthy" -or (docker-compose ps $ContainerName | Select-String "Up")) {
                Write-Success "Contenedor '$ContainerName' esta listo (intento $i/$MaxAttempts)"
                return $true
            }
        } catch {}
        
        Write-Status "Esperando contenedor '$ContainerName'... (intento $i/$MaxAttempts)"
        Start-Sleep -Seconds $SleepSeconds
    }
    
    Write-Warning "Contenedor '$ContainerName' no esta completamente listo, pero continuando..."
    return $false
}

# Funcion para ejecutar comandos de Artisan con reintentos
function Invoke-ArtisanCommand {
    param(
        [string]$Command,
        [string]$Description,
        [int]$MaxAttempts = 3
    )
    
    Write-Progress $Description
    
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            Write-Status "Ejecutando: $Command (intento $i/$MaxAttempts)"
            docker-compose exec -T foro_academico $Command
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "$Description completado exitosamente"
                return $true
            }
        } catch {
            Write-Warning "Error en intento ${i}: $($_.Exception.Message)"
        }
        
        if ($i -lt $MaxAttempts) {
            Write-Status "Reintentando en 5 segundos..."
            Start-Sleep -Seconds 5
        }
    }
    
    Write-Error "$Description fallo despues de $MaxAttempts intentos"
    return $false
}

Write-Host "=== FORO ACADEMICO - CONFIGURACION AUTOMATICA ===" -ForegroundColor Cyan
Write-Host "Iniciando configuracion completa del entorno..." -ForegroundColor Cyan
Write-Host ""

# Verificar prerrequisitos
Write-Status "Verificando prerrequisitos del sistema..."

# Verificar si Docker esta instalado y corriendo
try {
    $dockerVersion = docker --version
    Write-Success "Docker encontrado: $dockerVersion"
    
    # Verificar si Docker esta corriendo
    docker ps | Out-Null
    Write-Success "Docker daemon esta corriendo"
} catch {
    Write-Error "Docker no esta instalado o no esta corriendo. Por favor, instala e inicia Docker Desktop."
    Write-Host "Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar si Docker Compose esta disponible
try {
    $composeVersion = docker-compose --version
    Write-Success "Docker Compose encontrado: $composeVersion"
} catch {
    Write-Error "Docker Compose no esta disponible."
    exit 1
}

# Limpiar contenedores existentes si se solicita
if ($Clean) {
    Write-Status "Limpiando contenedores existentes..."
    docker-compose down -v --remove-orphans 2>$null
    docker system prune -f 2>$null
    Write-Success "Limpieza completada"
}

# Configurar archivo .env
Write-Status "Configurando archivo de entorno..."

if (!(Test-Path ".env") -or $Force) {
    Write-Progress "Creando archivo .env desde plantilla..."
    
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Success "Archivo .env creado desde .env.example"
    } else {
        Write-Error "No se encontro .env.example. Creando configuracion basica..."
        @"
APP_NAME="Foro Academico"
APP_ENV=$Environment
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8080
APP_FORCE_HTTPS=false

DB_CONNECTION=pgsql
DB_HOST=postgres_foro_academico
DB_PORT=5432
DB_DATABASE=foro_academico
DB_USERNAME=foro_user
DB_PASSWORD=foro_password

JWT_SECRET=
JWT_TTL=1440

CACHE_DRIVER=database
SESSION_DRIVER=database
QUEUE_CONNECTION=database

FILESYSTEM_DISK=local
"@ | Out-File -FilePath ".env" -Encoding UTF8
    }
    
    # Configurar entorno segun parametro
    Write-Progress "Configurando entorno para: $Environment"
    (Get-Content ".env") -replace "APP_ENV=.*", "APP_ENV=$Environment" | Set-Content ".env"
    
    if ($Environment -eq "production") {
        (Get-Content ".env") -replace "APP_DEBUG=.*", "APP_DEBUG=false" | Set-Content ".env"
        (Get-Content ".env") -replace "APP_FORCE_HTTPS=.*", "APP_FORCE_HTTPS=true" | Set-Content ".env"
    }
    
    # Generar APP_KEY si no existe
    if ((Get-Content ".env" | Select-String "APP_KEY=").Line -match "APP_KEY=$") {
        Write-Progress "Generando APP_KEY..."
        $appKey = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((New-Guid).ToString() + (New-Guid).ToString()))
        (Get-Content ".env") -replace "APP_KEY=", "APP_KEY=base64:$appKey" | Set-Content ".env"
        Write-Success "APP_KEY generado"
    }
    
    # Generar JWT_SECRET si no existe
    if ((Get-Content ".env" | Select-String "JWT_SECRET=").Line -match "JWT_SECRET=$") {
        Write-Progress "Generando JWT_SECRET..."
        $jwtSecret = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((New-Guid).ToString() + (New-Guid).ToString() + (New-Guid).ToString()))
        (Get-Content ".env") -replace "JWT_SECRET=", "JWT_SECRET=$jwtSecret" | Set-Content ".env"
        Write-Success "JWT_SECRET generado"
    }
    
    Write-Success "Archivo .env configurado correctamente"
} else {
    Write-Success "Archivo .env ya existe y esta configurado"
}

# Crear estructura de directorios
Write-Status "Configurando estructura de directorios..."
$directories = @(
    "storage\logs",
    "storage\framework\cache",
    "storage\framework\sessions", 
    "storage\framework\views",
    "storage\app\public\uploads\images",
    "storage\app\public\uploads\documents", 
    "storage\app\public\uploads\videos",
    "storage\app\public\uploads\audios",
    "bootstrap\cache",
    "docker\ssl"
)

$directoriesCreated = 0
foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        try {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $directoriesCreated++
        } catch {
            Write-Warning "No se pudo crear el directorio: $dir"
        }
    }
}

if ($directoriesCreated -gt 0) {
    Write-Success "Se crearon $directoriesCreated directorios"
} else {
    Write-Success "Estructura de directorios ya existe"
}

# Configurar permisos en Windows (si es posible)
try {
    icacls "storage" /grant Everyone:F /T /Q 2>$null | Out-Null
    icacls "bootstrap\cache" /grant Everyone:F /T /Q 2>$null | Out-Null
    Write-Success "Permisos de directorios configurados"
} catch {
    Write-Warning "No se pudieron configurar permisos automaticamente"
}

# Construccion y despliegue de contenedores
Write-Status "Iniciando construccion y despliegue de contenedores..."

if (!$SkipBuild) {
    Write-Progress "Construyendo imagenes Docker (esto puede tomar varios minutos)..."
    Write-Host "Construccion en progreso..." -ForegroundColor Yellow
    
    # Construir sin cache para asegurar la ultima version
    $buildResult = docker-compose build --no-cache --progress=plain
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error durante la construccion de contenedores"
        Write-Host "Intentando construccion con cache..." -ForegroundColor Yellow
        docker-compose build
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Error critico en la construccion. Revisa los logs arriba."
            exit 1
        }
    }
    
    Write-Success "Construccion de imagenes completada"
}

Write-Progress "Iniciando servicios de la aplicacion..."

# Detener servicios existentes primero
docker-compose down 2>$null

# Iniciar servicios en modo detached
docker-compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error al iniciar los servicios"
    Write-Status "Intentando diagnostico..."
    docker-compose ps
    docker-compose logs --tail=20
    exit 1
}

Write-Success "Servicios iniciados correctamente"

# Verificar estado de contenedores
Write-Status "Verificando estado de contenedores..."
Start-Sleep -Seconds 5

$containers = docker-compose ps -q
if ($containers) {
    Write-Success "Contenedores activos encontrados"
    docker-compose ps
} else {
    Write-Error "No se encontraron contenedores activos"
    exit 1
}

# Esperar a que los servicios esten listos
Write-Progress "Esperando a que los servicios esten completamente listos..."

# Esperar a PostgreSQL (externo)
Write-Status "Verificando conexion a PostgreSQL..."
$dbReady = $false
for ($i = 1; $i -le 20; $i++) {
    try {
        # Intentar conectar a la base de datos externa
        $testConnection = docker run --rm --network host postgres:15 pg_isready -h postgres_foro_academico -p 5432 -U foro_user 2>$null
        if ($LASTEXITCODE -eq 0) {
            $dbReady = $true
            break
        }
    } catch {}
    
    Write-Status "Esperando PostgreSQL... (intento $i/20)"
    Start-Sleep -Seconds 10
}

if ($dbReady) {
    Write-Success "PostgreSQL esta disponible"
} else {
    Write-Warning "PostgreSQL no responde, pero continuando con la configuracion..."
}

# Esperar a que la aplicacion este lista
Wait-ForContainer "foro_academico" -MaxAttempts 15 -SleepSeconds 8

# Configuracion de la aplicacion Laravel
Write-Status "Configurando aplicacion Laravel..."

# Instalar dependencias de Composer (si es necesario)
Write-Progress "Verificando dependencias de Composer..."
$hasVendor = docker-compose exec -T foro_academico test -d vendor 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Status "Instalando dependencias de Composer..."
    docker-compose exec -T foro_academico composer install --no-dev --optimize-autoloader
}

# Configurar aplicacion
Write-Progress "Configurando aplicacion Laravel..."

# Generar clave de aplicacion si es necesaria
Invoke-ArtisanCommand "php artisan key:generate --force" "Generacion de clave de aplicacion"

# Crear enlace simbolico para storage
Write-Progress "Configurando almacenamiento publico..."
docker-compose exec -T foro_academico php artisan storage:link 2>$null

# Ejecutar migraciones
$migrationSuccess = Invoke-ArtisanCommand "php artisan migrate --force" "Ejecucion de migraciones de base de datos"

if ($migrationSuccess) {
    Write-Success "Migraciones ejecutadas correctamente"
    
    # Ejecutar seeders solo si las migraciones fueron exitosas
    $seederSuccess = Invoke-ArtisanCommand "php artisan db:seed --force" "Poblacion de base de datos con datos iniciales"
    
    if ($seederSuccess) {
        Write-Success "Datos iniciales cargados correctamente"
    } else {
        Write-Warning "Algunos seeders fallaron, pero la aplicacion puede funcionar"
    }
} else {
    Write-Warning "Migraciones fallaron. La aplicacion puede no funcionar correctamente."
}

# Optimizar aplicacion
Write-Progress "Optimizando configuracion de la aplicacion..."
docker-compose exec -T foro_academico php artisan config:cache 2>$null
docker-compose exec -T foro_academico php artisan route:cache 2>$null
docker-compose exec -T foro_academico php artisan view:cache 2>$null

Write-Success "Configuracion de Laravel completada"

# Verificacion final y reporte de estado
Write-Progress "Realizando verificacion final del sistema..."

# Verificar estado de contenedores
Write-Status "Estado final de contenedores:"
docker-compose ps

# Verificar conectividad de la aplicacion
Write-Status "Verificando conectividad de la aplicacion..."
try {
    Start-Sleep -Seconds 5
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 30 -UseBasicParsing 2>$null
    if ($response.StatusCode -eq 200) {
        Write-Success "Aplicacion responde correctamente en http://localhost:8080"
    }
} catch {
    Write-Warning "La aplicacion puede estar iniciandose aun. Verifica manualmente en http://localhost:8080"
}

# Mostrar logs recientes si hay errores
$hasErrors = docker-compose logs --tail=50 2>&1 | Select-String -Pattern "ERROR|FATAL|Exception" -Quiet
if ($hasErrors) {
    Write-Warning "Se detectaron errores en los logs. Ultimas lineas:"
    docker-compose logs --tail=20
}

Write-Host ""
Write-Host "=== CONFIGURACION COMPLETADA EXITOSAMENTE ===" -ForegroundColor Green
Write-Host ""
Write-Success "Foro Academico esta listo para usar!"
Write-Host ""
Write-Host "SERVICIOS DISPONIBLES:" -ForegroundColor White
Write-Host "   - Aplicacion Web: http://localhost:8080" -ForegroundColor Cyan
Write-Host "   - API Backend: http://localhost:8080/api" -ForegroundColor Cyan
Write-Host "   - Base de datos PostgreSQL: localhost:5432" -ForegroundColor Gray
Write-Host ""
Write-Host "ENDPOINTS DE EJEMPLO:" -ForegroundColor White
Write-Host "   - Categorias: http://localhost:8080/api/categories" -ForegroundColor Gray
Write-Host "   - Preguntas: http://localhost:8080/api/questions" -ForegroundColor Gray
Write-Host "   - Usuarios: http://localhost:8080/api/auth/register" -ForegroundColor Gray
Write-Host ""
Write-Host "COMANDOS UTILES:" -ForegroundColor White
Write-Host "   - Ver logs: docker-compose logs -f" -ForegroundColor Yellow
Write-Host "   - Parar servicios: docker-compose down" -ForegroundColor Yellow
Write-Host "   - Reiniciar: docker-compose restart" -ForegroundColor Yellow
Write-Host "   - Acceder al contenedor: docker-compose exec foro_academico bash" -ForegroundColor Yellow
Write-Host "   - Ver estado: docker-compose ps" -ForegroundColor Yellow
Write-Host ""
Write-Host "GESTION SSL:" -ForegroundColor White
Write-Host "   - Generar certificados dev: ./docker/ssl-manager.sh dev" -ForegroundColor Gray
Write-Host "   - Estado SSL: ./docker/ssl-manager.sh status" -ForegroundColor Gray
Write-Host ""

if ($Environment -eq "production") {
    Write-Host "CONFIGURACION DE PRODUCCION ACTIVA:" -ForegroundColor Red
    Write-Host "   - HTTPS habilitado automaticamente" -ForegroundColor Yellow
    Write-Host "   - Certificados SSL configurados" -ForegroundColor Yellow
    Write-Host "   - Headers de seguridad aplicados" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Para mas informacion, consulta docker/README.md" -ForegroundColor Cyan
Write-Host ""
Write-Success "Disfruta desarrollando con Foro Academico!"

# Abrir navegador automaticamente (opcional)
$openBrowser = Read-Host "Deseas abrir la aplicacion en el navegador? (y/N)"
if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
    try {
        Start-Process "http://localhost:8080"
        Write-Success "Navegador abierto automaticamente"
    } catch {
        Write-Warning "No se pudo abrir el navegador automaticamente"
    }
}
