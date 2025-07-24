# GestLab Docker - Guía de Despliegue

## 📋 Requisitos Previos

- **Docker Desktop** instalado y funcionando
- **Windows 10/11** con WSL2 habilitado (recomendado)
- **8GB RAM** mínimo
- **10GB** de espacio libre en disco

## 🚀 Instalación Rápida

### 1. Configuración Inicial (Solo la primera vez)

```powershell
# Ejecutar desde PowerShell como Administrador
.\scripts\setup-windows.ps1
```

### 2. Construcción e Inicio

```powershell
# Construir e iniciar todos los contenedores
.\scripts\gestlab-docker.ps1 build
```

### 3. Acceder a la Aplicación

- **Aplicación Principal**: http://localhost:8000
- **phpMyAdmin**: http://localhost:8080
- **Backups**: C:\backup

## 🎮 Comandos Principales

```powershell
# Iniciar servicios
.\scripts\gestlab-docker.ps1 start

# Detener servicios
.\scripts\gestlab-docker.ps1 stop

# Reiniciar servicios
.\scripts\gestlab-docker.ps1 restart

# Ver logs en tiempo real
.\scripts\gestlab-docker.ps1 logs

# Ver estado de contenedores
.\scripts\gestlab-docker.ps1 status

# Crear backup manual
.\scripts\gestlab-docker.ps1 backup

# Restaurar desde backup
.\scripts\gestlab-docker.ps1 restore -BackupFile "C:\backup\archivo.sql"

# Limpiar todo (cuidado: elimina datos)
.\scripts\gestlab-docker.ps1 clean
```

## 🗃️ Sistema de Backup Automático

### Características:
- **Backup automático cada hora**
- **Ubicación**: `C:\backup\`
- **Retención**: Últimas 24 horas
- **Formato**: `gestlab_backup_YYYYMMDD_HHMMSS.sql`

### Funcionamiento:
1. **Primera ejecución**: Se ejecutan migraciones y seeders
2. **Reinicios posteriores**: Se restaura automáticamente desde el backup más reciente
3. **Backup continuo**: Cada hora se crea un nuevo backup automáticamente

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Laravel App   │    │     MySQL       │    │   phpMyAdmin    │
│   (Puerto 8000) │◄──►│   (Puerto 3306) │◄──►│   (Puerto 8080) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   C:\backup     │
                    │   (Volumen)     │
                    └─────────────────┘
```

## 🔧 Configuración Avanzada

### Variables de Entorno (docker-compose.yml)
```yaml
environment:
  - APP_ENV=production
  - DB_HOST=db
  - DB_DATABASE=gestlab
  - DB_USERNAME=gestlab_user
  - DB_PASSWORD=gestlab_password
```

### Puertos Personalizados

Para cambiar puertos, edita `docker-compose.yml`:

```yaml
services:
  app:
    ports:
      - "8080:80"  # Cambiar puerto de la app
  db:
    ports:
      - "3308:3306"  # Cambiar puerto de MySQL (actualmente en 3307)
```

## 🔍 Solución de Problemas

### Error: Puerto ya en uso
```powershell
# Verificar qué está usando el puerto
netstat -ano | findstr :8000

# Detener proceso si es necesario
taskkill /PID [PID_NUMBER] /F
```

### Error: Docker no responde
```powershell
# Reiniciar Docker Desktop
.\scripts\gestlab-docker.ps1 stop
# Reiniciar Docker Desktop desde el menú
.\scripts\gestlab-docker.ps1 start
```

### Error: Base de datos corrupta
```powershell
# Limpiar todo y empezar de nuevo
.\scripts\gestlab-docker.ps1 clean
.\scripts\gestlab-docker.ps1 build
```

### Restaurar backup específico
```powershell
# Listar backups disponibles
Get-ChildItem C:\backup\*.sql | Sort-Object LastWriteTime -Descending

# Restaurar backup específico
.\scripts\gestlab-docker.ps1 restore -BackupFile "C:\backup\gestlab_backup_20250723_140000.sql"
```

## 📂 Estructura de Archivos

```
APWII-GestLab/
├── docker/
│   ├── vhost.conf          # Configuración Apache
│   ├── entrypoint.sh       # Script de inicialización
│   ├── backup.sh           # Script de backup automático
│   └── init-db.sh          # Inicialización MySQL
├── scripts/
│   ├── gestlab-docker.ps1  # Script principal PowerShell
│   ├── gestlab-docker.sh   # Script principal Bash
│   └── setup-windows.ps1   # Configuración inicial
├── Dockerfile              # Imagen del contenedor
├── docker-compose.yml      # Orquestación de servicios
└── .env.docker            # Variables de entorno para Docker
```

## 🔐 Credenciales Predeterminadas

### Base de Datos MySQL:
- **Host**: localhost:3307 (puerto cambiado para evitar conflictos)
- **Database**: gestlab
- **Usuario**: gestlab_user
- **Contraseña**: gestlab_password
- **Root**: root_password

### phpMyAdmin:
- **URL**: http://localhost:8080
- **Usuario**: gestlab_user
- **Contraseña**: gestlab_password

### Aplicación Laravel:
Los usuarios se crean mediante seeders. Verifica el archivo `UserSeeder.php` para las credenciales iniciales.

## 📞 Soporte

Para problemas o preguntas:
1. Verifica los logs: `.\scripts\gestlab-docker.ps1 logs`
2. Revisa el estado: `.\scripts\gestlab-docker.ps1 status`
3. Consulta este README
4. Reinicia si es necesario: `.\scripts\gestlab-docker.ps1 restart`
