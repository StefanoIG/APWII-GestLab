# GestLab - Arquitectura de 3 Contenedores Separados

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                     GestLab Stack                          │
├─────────────────────────────────────────────────────────────┤
│  🌐 Nginx (Puerto 8000)                                    │
│      ↓ FastCGI                                             │
│  🚀 Laravel App (PHP-FPM 9000)                             │
│      ↓ MySQL Connection                                    │
│  🗄️ MySQL Database (Puerto 3307)                           │
└─────────────────────────────────────────────────────────────┘

📁 C:\gestlab-db\          # Base de datos independiente
📁 C:\backup\              # Backups automáticos  
📁 C:\projects\APWII-GestLab\  # Aplicación + Nginx
```

## 🚀 Instalación Rápida

### 1. Configuración inicial (solo una vez)
```powershell
cd C:\projects\APWII-GestLab
.\scripts\setup-3containers.ps1
```

### 2. Iniciar todos los contenedores
```powershell
.\scripts\gestlab-3containers.ps1 start
```

### 3. Acceso
- **Aplicación**: http://localhost:8000
- **phpMyAdmin**: http://localhost:8080
- **MySQL**: localhost:3307

## 🎮 Gestión de Contenedores

### Comandos principales
```powershell
# Iniciar todo
.\scripts\gestlab-3containers.ps1 start

# Detener todo
.\scripts\gestlab-3containers.ps1 stop

# Reiniciar todo
.\scripts\gestlab-3containers.ps1 restart

# Construir desde cero
.\scripts\gestlab-3containers.ps1 build

# Ver estado
.\scripts\gestlab-3containers.ps1 status

# Ver logs
.\scripts\gestlab-3containers.ps1 logs
```

### Gestión independiente
```powershell
# Solo base de datos
.\scripts\gestlab-3containers.ps1 start-db
.\scripts\gestlab-3containers.ps1 stop-db

# Solo aplicación (requiere que BD esté corriendo)
.\scripts\gestlab-3containers.ps1 start-app
.\scripts\gestlab-3containers.ps1 stop-app
```

## 📁 Estructura de Archivos

### Aplicación Laravel + Nginx
```
C:\projects\APWII-GestLab\
├── Dockerfile                     # Laravel PHP-FPM
├── docker-compose.yml             # App + Nginx + referencia a BD
├── docker\
│   ├── Dockerfile.nginx           # Nginx container
│   ├── nginx.conf                 # Configuración Nginx
│   ├── default.conf               # Virtual host Laravel
│   ├── app-entrypoint.sh          # Inicialización Laravel
│   └── logs\                      # Logs de Nginx
└── scripts\
    ├── setup-3containers.ps1      # Configuración inicial
    └── gestlab-3containers.ps1    # Gestión de contenedores
```

### Base de Datos (Carpeta Separada)
```
C:\gestlab-db\
├── docker-compose.yml             # Solo MySQL
├── data\                          # Datos de MySQL (persistente)
└── docker\
    ├── init-db.sh                 # Inicialización DB
    └── backup.sh                  # Script de backup
```

### Backups
```
C:\backup\
├── gestlab_backup_20250723_140000.sql
├── gestlab_backup_20250723_150000.sql
└── ...                           # Últimas 24 horas de backups
```

## 🔧 Configuración Avanzada

### Cambiar puertos
Edita `docker-compose.yml` en cada directorio:

**Aplicación (C:\projects\APWII-GestLab\docker-compose.yml):**
```yaml
gestlab-nginx:
  ports:
    - "8080:80"  # Cambiar puerto web
```

**Base de datos (C:\gestlab-db\docker-compose.yml):**
```yaml
gestlab-db:
  ports:
    - "3308:3306"  # Cambiar puerto MySQL
```

### Variables de entorno
Edita `.env.docker` para configuración de producción:
```env
DB_HOST=gestlab-db
DB_PORT=3306
DB_DATABASE=gestlab
DB_USERNAME=gestlab_user
DB_PASSWORD=gestlab_password
```

## 🗃️ Sistema de Backup

### Características
- ✅ Backup automático cada hora
- ✅ Retención de 24 backups
- ✅ Ubicación: `C:\backup\`
- ✅ Restauración automática al reiniciar

### Funcionamiento
1. **Primera ejecución**: Ejecuta migraciones y seeders
2. **Reinicios posteriores**: Restaura desde backup más reciente
3. **Backup continuo**: Cada hora crea nuevo backup automáticamente

### Backup manual
```powershell
# Crear backup manual
docker exec gestlab-db /usr/local/bin/backup.sh

# Restaurar backup específico
docker exec -i gestlab-db mysql -u gestlab_user -pgestlab_password gestlab < C:\backup\archivo.sql
```

## 🔍 Troubleshooting

### Error: Red no existe
```powershell
docker network create gestlab-network
```

### Error: Puerto en uso
```powershell
# Ver qué usa el puerto
netstat -ano | findstr :8000

# Cambiar puerto en docker-compose.yml
```

### Base de datos no conecta
```powershell
# Verificar que la BD esté corriendo
.\scripts\gestlab-3containers.ps1 status

# Iniciar solo la BD
.\scripts\gestlab-3containers.ps1 start-db

# Ver logs de la BD
cd C:\gestlab-db
docker compose logs
```

### Aplicación no responde
```powershell
# Verificar logs de Nginx
type docker\logs\gestlab_error.log

# Verificar logs de Laravel
.\scripts\gestlab-3containers.ps1 logs
```

### Limpiar todo y empezar de nuevo
```powershell
.\scripts\gestlab-3containers.ps1 clean
.\scripts\gestlab-3containers.ps1 build
```

## 🔐 Credenciales

### MySQL
- **Host**: localhost:3307
- **Usuario**: gestlab_user
- **Contraseña**: gestlab_password
- **Base de datos**: gestlab

### phpMyAdmin
- **URL**: http://localhost:8080
- **Usuario**: gestlab_user
- **Contraseña**: gestlab_password

### Aplicación Laravel
Los usuarios se crean con seeders. Credencial por defecto:
- **Email**: admin@example.com
- **Contraseña**: password

## 📞 Soporte

1. **Ver estado**: `.\scripts\gestlab-3containers.ps1 status`
2. **Ver logs**: `.\scripts\gestlab-3containers.ps1 logs`
3. **Reiniciar**: `.\scripts\gestlab-3containers.ps1 restart`
4. **Reconstruir**: `.\scripts\gestlab-3containers.ps1 build`

---

## 🎯 Ventajas de esta Arquitectura

- ✅ **Separación clara**: Cada servicio en su contenedor
- ✅ **Escalabilidad**: Fácil escalar cada servicio independientemente
- ✅ **Mantenimiento**: Actualizar servicios sin afectar otros
- ✅ **Backup independiente**: BD en carpeta separada con backups automáticos
- ✅ **Performance**: Nginx optimizado para servir contenido estático
- ✅ **Desarrollo**: Fácil debug de cada componente por separado
