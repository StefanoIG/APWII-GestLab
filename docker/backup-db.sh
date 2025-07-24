#!/bin/bash

# Script de backup automático para MySQL (desde contenedor DB)
BACKUP_DIR="/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/gestlab_backup_$TIMESTAMP.sql"

# Crear directorio de backup si no existe
mkdir -p $BACKUP_DIR

# Realizar backup
echo "Creando backup: $BACKUP_FILE"
mysqldump -u gestlab_user -pgestlab_password gestlab > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup creado exitosamente: $BACKUP_FILE"
    
    # Mantener solo los últimos 24 backups (uno por hora durante 24 horas)
    cd $BACKUP_DIR
    ls -t gestlab_backup_*.sql | tail -n +25 | xargs -r rm
    echo "Backups antiguos eliminados. Manteniendo los últimos 24."
else
    echo "Error al crear backup"
    rm -f "$BACKUP_FILE"
fi
