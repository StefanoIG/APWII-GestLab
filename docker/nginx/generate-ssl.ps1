# Script para generar certificados SSL auto-firmados para Nginx
$sslPath = "$PSScriptRoot\ssl"
$certFile = "$sslPath\cert.pem"
$keyFile = "$sslPath\key.pem"
$dhparamFile = "$sslPath\dhparam.pem"

if (!(Test-Path $sslPath)) {
    New-Item -ItemType Directory -Path $sslPath -Force | Out-Null
}

Write-Host "Generando certificados SSL auto-firmados para localhost..." -ForegroundColor Yellow

# Generar certificado y clave privada
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $keyFile -out $certFile -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

# Generar parámetros Diffie-Hellman
Write-Host "Generando parámetros Diffie-Hellman (esto puede tomar un momento)..." -ForegroundColor Yellow
openssl dhparam -out $dhparamFile 2048

Write-Host "Certificados SSL generados exitosamente:" -ForegroundColor Green
Write-Host "  - Certificado: $certFile" -ForegroundColor Cyan
Write-Host "  - Clave privada: $keyFile" -ForegroundColor Cyan
Write-Host "  - DH Params: $dhparamFile" -ForegroundColor Cyan
