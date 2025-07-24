#!/bin/bash

# Script de inicialización para Laravel App (PHP-FPM)
echo "Iniciando GestLab Laravel Application..."

# Esperar a que MySQL esté disponible usando PHP
echo "Esperando a que MySQL esté disponible..."
while ! php -r "
try {
    \$pdo = new PDO('mysql:host=gestlab-db;port=3306', 'gestlab_user', 'gestlab_password');
    echo 'Connected';
    exit(0);
} catch (Exception \$e) {
    exit(1);
}"; do
    echo "Esperando conexión a MySQL..."
    sleep 2
done
echo "MySQL está disponible!"

# Ejecutar migraciones y seeders de Laravel
echo "Ejecutando migraciones..."
php artisan migrate --force
echo "Ejecutando seeders..."
php artisan db:seed --force
echo "Migraciones y seeders completados."

# Optimizar Laravel para producción
echo "Optimizando Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Iniciando PHP-FPM..."
exec "$@"
