#!/bin/bash

# GestLab SSL Certificate Manager
# Gestiona certificados SSL para desarrollo y producción

set -e

SSL_DIR="/etc/nginx/ssl"
CERT_FILE="$SSL_DIR/cert.pem"
KEY_FILE="$SSL_DIR/key.pem" 
DHPARAM_FILE="$SSL_DIR/dhparam.pem"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    echo "GestLab SSL Certificate Manager"
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  dev       - Generar certificados para desarrollo"
    echo "  prod      - Generar certificados para producción"
    echo "  status    - Mostrar estado de certificados"
    echo "  verify    - Verificar certificados existentes"
    echo "  clean     - Limpiar certificados existentes"
    echo "  help      - Mostrar esta ayuda"
    echo ""
}

ensure_ssl_dir() {
    if [ ! -d "$SSL_DIR" ]; then
        print_status "Creando directorio SSL: $SSL_DIR"
        mkdir -p "$SSL_DIR"
    fi
}

generate_dev_certs() {
    print_status "Generando certificados SSL para desarrollo..."
    
    ensure_ssl_dir
    
    # Generar clave privada
    print_status "Generando clave privada..."
    openssl genrsa -out "$KEY_FILE" 2048
    
    # Generar certificado autofirmado
    print_status "Generando certificado autofirmado..."
    openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days 365 \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=GestLab/OU=Development/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1,IP:::1"
    
    # Generar parámetros DH
    print_status "Generando parámetros Diffie-Hellman (esto puede tomar tiempo)..."
    openssl dhparam -out "$DHPARAM_FILE" 2048
    
    # Establecer permisos correctos
    chmod 600 "$KEY_FILE"
    chmod 644 "$CERT_FILE"
    chmod 644 "$DHPARAM_FILE"
    
    print_success "Certificados de desarrollo generados exitosamente"
    show_cert_info
}

generate_prod_certs() {
    print_status "Generando certificados SSL para producción..."
    
    ensure_ssl_dir
    
    # Para producción, generamos certificados más robustos
    print_status "Generando clave privada RSA-4096..."
    openssl genrsa -out "$KEY_FILE" 4096
    
    # Crear archivo de configuración para el certificado
    cat > /tmp/cert.conf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = ES
ST = Madrid
L = Madrid
O = GestLab
OU = Production
CN = localhost

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
DNS.3 = gestlab.local
DNS.4 = *.gestlab.local
IP.1 = 127.0.0.1
IP.2 = ::1
EOF
    
    # Generar certificado con configuración extendida
    print_status "Generando certificado con configuración extendida..."
    openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days 730 \
        -config /tmp/cert.conf -extensions v3_req
    
    # Generar parámetros DH más fuertes para producción
    print_status "Generando parámetros Diffie-Hellman 4096 bits (esto tomará varios minutos)..."
    openssl dhparam -out "$DHPARAM_FILE" 4096
    
    # Limpiar archivo temporal
    rm /tmp/cert.conf
    
    # Establecer permisos correctos
    chmod 600 "$KEY_FILE"
    chmod 644 "$CERT_FILE"
    chmod 644 "$DHPARAM_FILE"
    
    print_success "Certificados de producción generados exitosamente"
    show_cert_info
}

show_status() {
    echo "GestLab SSL Certificate Status"
    echo "=============================="
    
    if [ -f "$CERT_FILE" ]; then
        print_success "Certificado encontrado: $CERT_FILE"
        
        # Mostrar información del certificado
        echo ""
        echo "Información del certificado:"
        openssl x509 -in "$CERT_FILE" -text -noout | grep -E "(Subject:|Issuer:|Not Before|Not After|Subject Alternative Name)" || true
        
        # Verificar validez
        if openssl x509 -in "$CERT_FILE" -checkend 86400 > /dev/null 2>&1; then
            print_success "Certificado válido (no expira en las próximas 24 horas)"
        else
            print_warning "Certificado expirará pronto o ya expiró"
        fi
    else
        print_error "Certificado no encontrado: $CERT_FILE"
    fi
    
    if [ -f "$KEY_FILE" ]; then
        print_success "Clave privada encontrada: $KEY_FILE"
    else
        print_error "Clave privada no encontrada: $KEY_FILE"
    fi
    
    if [ -f "$DHPARAM_FILE" ]; then
        print_success "Parámetros DH encontrados: $DHPARAM_FILE"
    else
        print_error "Parámetros DH no encontrados: $DHPARAM_FILE"
    fi
}

show_cert_info() {
    if [ -f "$CERT_FILE" ]; then
        echo ""
        echo "=== Información del Certificado Generado ==="
        openssl x509 -in "$CERT_FILE" -text -noout | head -20
        echo ""
        print_success "Certificado listo para usar con Nginx"
    fi
}

verify_certs() {
    print_status "Verificando certificados SSL..."
    
    if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
        print_error "Certificados no encontrados"
        return 1
    fi
    
    # Verificar que el certificado y la clave coincidan
    cert_hash=$(openssl x509 -noout -modulus -in "$CERT_FILE" | openssl md5)
    key_hash=$(openssl rsa -noout -modulus -in "$KEY_FILE" | openssl md5)
    
    if [ "$cert_hash" = "$key_hash" ]; then
        print_success "Certificado y clave privada coinciden"
    else
        print_error "Certificado y clave privada NO coinciden"
        return 1
    fi
    
    # Verificar certificado
    if openssl x509 -in "$CERT_FILE" -text -noout > /dev/null 2>&1; then
        print_success "Certificado es válido"
    else
        print_error "Certificado inválido"
        return 1
    fi
    
    # Verificar clave privada
    if openssl rsa -in "$KEY_FILE" -check > /dev/null 2>&1; then
        print_success "Clave privada es válida"
    else
        print_error "Clave privada inválida"
        return 1
    fi
    
    print_success "Todos los certificados son válidos"
}

clean_certs() {
    print_warning "¿Estás seguro de que quieres eliminar todos los certificados SSL? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Eliminando certificados SSL..."
        rm -f "$CERT_FILE" "$KEY_FILE" "$DHPARAM_FILE"
        print_success "Certificados eliminados"
    else
        print_status "Operación cancelada"
    fi
}

# Comando principal
case "${1:-help}" in
    "dev")
        generate_dev_certs
        ;;
    "prod")
        generate_prod_certs
        ;;
    "status")
        show_status
        ;;
    "verify")
        verify_certs
        ;;
    "clean")
        clean_certs
        ;;
    "help"|*)
        show_help
        ;;
esac
