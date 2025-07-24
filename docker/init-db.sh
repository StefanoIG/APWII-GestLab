#!/bin/bash

# Script de inicialización para MySQL
echo "Inicializando base de datos MySQL para GestLab..."

# El contenedor MySQL ya crea la base de datos y usuario
# Este script se ejecuta solo una vez cuando se crea el contenedor
echo "Base de datos 'gestlab' creada."
echo "Usuario 'gestlab_user' creado."
echo "MySQL listo para recibir conexiones."
