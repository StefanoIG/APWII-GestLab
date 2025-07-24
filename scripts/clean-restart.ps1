# Script para limpiar y reiniciar GestLab Docker
Write-Host "🧹 Limpiando contenedores existentes..." -ForegroundColor Yellow

# Detener y eliminar contenedores existentes
try {
    docker compose down -v 2>$null
} catch {
    try {
        docker-compose down -v 2>$null
    } catch {
        Write-Host "No hay contenedores anteriores para limpiar" -ForegroundColor Gray
    }
}

# Limpiar imágenes no utilizadas
Write-Host "🗑️ Limpiando imágenes no utilizadas..." -ForegroundColor Yellow
docker system prune -f

Write-Host "✅ Limpieza completada!" -ForegroundColor Green
Write-Host "`n🚀 Iniciando contenedores frescos..." -ForegroundColor Cyan

# Construir e iniciar
try {
    docker compose build --no-cache
    docker compose up -d
} catch {
    try {
        docker-compose build --no-cache
        docker-compose up -d
    } catch {
        Write-Host "❌ Error al iniciar contenedores" -ForegroundColor Red
        exit 1
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 ¡GestLab iniciado exitosamente!" -ForegroundColor Green
    Write-Host "🌐 Aplicación: http://localhost:8000" -ForegroundColor Cyan
    Write-Host "🗄️ phpMyAdmin: http://localhost:8080" -ForegroundColor Cyan
    Write-Host "🗃️ MySQL: localhost:3307 (puerto cambiado para evitar conflictos)" -ForegroundColor Cyan
    
    Write-Host "`n📊 Estado de contenedores:" -ForegroundColor Yellow
    try {
        docker compose ps
    } catch {
        docker-compose ps
    }
} else {
    Write-Host "❌ Error al iniciar los contenedores" -ForegroundColor Red
}
