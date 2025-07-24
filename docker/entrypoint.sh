#!/bin/bash

# Script de inicialización para el contenedor Laravel
echo "Iniciando GestLab Laravel Application..."

# Esperar a que MySQL esté disponible
echo "Esperando a que MySQL esté disponible..."
while ! mysqladmin ping -h"db" -u"gestlab_user" -p"gestlab_password" --silent; do
    sleep 2
done
echo "MySQL está disponible!"

# Verificar si existe backup y la base de datos está vacía
BACKUP_EXISTS=$(ls /backup/*.sql 2>/dev/null | wc -l)
TABLES_COUNT=$(mysql -h db -u gestlab_user -pgestlab_password gestlab -e "SHOW TABLES;" 2>/dev/null | wc -l)

if [ $BACKUP_EXISTS -gt 0 ] && [ $TABLES_COUNT -le 1 ]; then
    echo "Se encontró backup y la base de datos está vacía. Restaurando desde backup..."
    LATEST_BACKUP=$(ls -t /backup/*.sql | head -n1)
    mysql -h db -u gestlab_user -pgestlab_password gestlab < "$LATEST_BACKUP"
    echo "Backup restaurado exitosamente desde: $LATEST_BACKUP"
elif [ $TABLES_COUNT -le 1 ]; then
    echo "No se encontró backup o la base de datos está vacía. Ejecutando migraciones..."
    php artisan migrate --force
    echo "Ejecutando seeders..."
    php artisan db:seed --force
    echo "Migraciones y seeders completados."
    
    # Crear primer backup después de las migraciones
    echo "Creando backup inicial..."
    /usr/local/bin/backup.sh
else
    echo "La base de datos ya contiene datos. Saltando migraciones."
fi

# Optimizar Laravel para producción
echo "Optimizando Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Iniciar cron para backups automáticos
echo "Iniciando servicio cron..."
service cron start

echo "Iniciando Apache..."
exec "$@"
