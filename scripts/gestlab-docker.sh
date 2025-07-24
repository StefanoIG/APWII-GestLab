#!/bin/bash

# Script Bash para gestionar GestLab Docker
# Uso: ./gestlab-docker.sh [comando]
# Comandos: start, stop, restart, build, logs, backup, restore, clean

COMMAND=$1
PROJECT_NAME="gestlab"
BACKUP_DIR="/c/backup"

function print_header() {
    echo "============================================="
    echo " $1"
    echo "============================================="
}

function ensure_backup_directory() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "Directorio de backup creado: $BACKUP_DIR"
    fi
}

function show_help() {
    echo "💡 Comandos disponibles:"
    echo "   start    - Iniciar contenedores"
    echo "   stop     - Detener contenedores"
    echo "   restart  - Reiniciar contenedores"
    echo "   build    - Construir e iniciar"
    echo "   logs     - Ver logs en tiempo real"
    echo "   backup   - Crear backup manual"
    echo "   restore  - Restaurar desde backup"
    echo "   clean    - Limpiar todo"
    echo "   status   - Ver estado y recursos"
}

case $COMMAND in
    "start")
        print_header "Iniciando GestLab Docker"
        ensure_backup_directory
        docker-compose up -d
        if [ $? -eq 0 ]; then
            echo "✅ GestLab iniciado exitosamente!"
            echo "🌐 Aplicación: http://localhost:8000"
            echo "🗄️  phpMyAdmin: http://localhost:8080"
        fi
        ;;
    
    "stop")
        print_header "Deteniendo GestLab Docker"
        docker-compose down
        echo "✅ GestLab detenido exitosamente!"
        ;;
    
    "restart")
        print_header "Reiniciando GestLab Docker"
        docker-compose down
        ensure_backup_directory
        docker-compose up -d
        if [ $? -eq 0 ]; then
            echo "✅ GestLab reiniciado exitosamente!"
        fi
        ;;
    
    "build")
        print_header "Construyendo GestLab Docker"
        ensure_backup_directory
        docker-compose build --no-cache
        docker-compose up -d
        if [ $? -eq 0 ]; then
            echo "✅ GestLab construido e iniciado exitosamente!"
        fi
        ;;
    
    "logs")
        print_header "Mostrando logs de GestLab"
        docker-compose logs -f
        ;;
    
    "backup")
        print_header "Creando backup manual"
        ensure_backup_directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        backup_file="$BACKUP_DIR/gestlab_manual_backup_$timestamp.sql"
        
        docker-compose exec db mysqldump -u gestlab_user -pgestlab_password gestlab > "$backup_file"
        if [ $? -eq 0 ]; then
            echo "✅ Backup creado: $backup_file"
        else
            echo "❌ Error al crear backup"
        fi
        ;;
    
    "restore")
        backup_file=$2
        if [ -z "$backup_file" ]; then
            echo "❌ Por favor especifica el archivo de backup:"
            echo "   ./gestlab-docker.sh restore /c/backup/archivo.sql"
            exit 1
        fi
        
        if [ ! -f "$backup_file" ]; then
            echo "❌ Archivo de backup no encontrado: $backup_file"
            exit 1
        fi
        
        print_header "Restaurando backup desde $backup_file"
        docker-compose exec -T db mysql -u gestlab_user -pgestlab_password gestlab < "$backup_file"
        if [ $? -eq 0 ]; then
            echo "✅ Backup restaurado exitosamente!"
        else
            echo "❌ Error al restaurar backup"
        fi
        ;;
    
    "clean")
        print_header "Limpiando GestLab Docker"
        docker-compose down -v
        docker system prune -f
        echo "✅ Limpieza completada!"
        ;;
    
    "status")
        print_header "Estado de GestLab Docker"
        docker-compose ps
        echo
        echo "📊 Uso de recursos:"
        docker stats --no-stream
        ;;
    
    *)
        echo "❌ Comando no reconocido: $COMMAND"
        show_help
        exit 1
        ;;
esac

echo
show_help
