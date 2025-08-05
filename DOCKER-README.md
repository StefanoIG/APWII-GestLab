# GestLab - Configuración Docker en Windows v2.0

## 🚀 Configuración inicial (solo una vez)

```powershell
# 1. Configurar el entorno
.\scripts\setup-gestlab.ps1

# 2. Construir e iniciar todos los contenedores
.\scripts\gestlab-smart.ps1 build
```

## 🎯 Detección Automática de Entorno

El sistema detecta automáticamente si estás en modo **local** o **production** basándose en el archivo `.env`:

- **Local**: `APP_ENV=local` → HTTP en puerto 8000
- **Production**: `APP_ENV=production` → HTTPS en puerto 8443 con SSL automático

### Cambiar entre entornos

```powershell
# Cambiar automáticamente entre local y production
.\scripts\gestlab-smart.ps1 switch-env

# Reiniciar para aplicar cambios
.\scripts\gestlab-smart.ps1 restart
```

## 📋 Uso diario

### Iniciar la aplicación
```powershell
.\scripts\gestlab-smart.ps1 start
```

### Detener la aplicación
```powershell
.\scripts\gestlab-smart.ps1 stop
```

### Ver estado de contenedores
```powershell
.\scripts\gestlab-smart.ps1 status
```

### Ver logs en tiempo real
```powershell
.\scripts\gestlab-smart.ps1 logs
```

## 🔗 Enlaces según entorno

### Modo Local (HTTP)
- **Aplicación Laravel**: <http://localhost:8000>
- **phpMyAdmin**: <http://localhost:8080>
- **Base de datos MySQL**: localhost:3307

### Modo Production (HTTPS)
- **Aplicación Laravel**: <https://localhost:8443>
- **Redirección HTTP**: <http://localhost:8000> → HTTPS
- **phpMyAdmin**: <http://localhost:8080>
- **Base de datos MySQL**: localhost:3307

## 📂 Estructura de contenedores

| Contenedor | Puerto Local | Puerto Prod | Función |
|------------|--------------|-------------|---------|
| `gestlab-app` | 9000 | 9000 | Aplicación Laravel (PHP-FPM) |
| `gestlab-nginx` | 8000 | 8000+8443 | Servidor web Nginx |
| `gestlab-db` | 3307 | 3307 | Base de datos MySQL |
| `gestlab-phpmyadmin` | 8080 | 8080 | Administrador de BD |

## 🔒 Configuración SSL Automática

En modo **production**:
- Certificados SSL generados automáticamente
- HTTPS forzado con redirección desde HTTP
- Headers de seguridad avanzada aplicados
- Certificados almacenados en `docker\nginx\ssl\`

## 💾 Persistencia de datos

- **Base de datos**: `C:\gestlab-db\data`
- **Backups**: `C:\backup`
- **Logs**: `C:\gestlab-db\logs`
- **Certificados SSL**: `docker\nginx\ssl\`

## 🔧 Comandos disponibles

```powershell
# Gestión completa
.\scripts\gestlab-smart.ps1 build      # Construir todo desde cero
.\scripts\gestlab-smart.ps1 start      # Iniciar todos los contenedores
.\scripts\gestlab-smart.ps1 stop       # Detener todos los contenedores
.\scripts\gestlab-smart.ps1 restart    # Reiniciar todos los contenedores
.\scripts\gestlab-smart.ps1 status     # Ver estado y recursos
.\scripts\gestlab-smart.ps1 logs       # Ver logs de todos los contenedores
.\scripts\gestlab-smart.ps1 clean      # Limpiar todo (CUIDADO: elimina datos)

# Gestión de entorno
.\scripts\gestlab-smart.ps1 switch-env # Cambiar entre local/production

# Gestión individual
.\scripts\gestlab-smart.ps1 start-db   # Solo base de datos
.\scripts\gestlab-smart.ps1 stop-db    # Solo base de datos
.\scripts\gestlab-smart.ps1 start-app  # Solo aplicación y nginx
.\scripts\gestlab-smart.ps1 stop-app   # Solo aplicación y nginx
```

## 🔄 Configuración de Entornos

### Archivos de configuración automática

- `.env.local` → Configuración para desarrollo
- `.env.production` → Configuración para producción
- `docker-compose.local.yml` → Servicios HTTP
- `docker-compose.production.yml` → Servicios HTTPS + SSL

### Variables de entorno importantes

```bash
# Configuración según entorno
APP_ENV=local|production
APP_DEBUG=true|false
APP_URL=http://localhost:8000|https://localhost:8443
APP_FORCE_HTTPS=false|true
SESSION_SECURE_COOKIE=false|true
SSL_ENABLED=false|true
```

## 🆘 Solución de problemas

### Error 502 Bad Gateway
```powershell
# Reiniciar contenedores
.\scripts\gestlab-smart.ps1 restart
```

### Cambiar de HTTP a HTTPS
```powershell
# Cambiar a producción (automáticamente configura SSL)
.\scripts\gestlab-smart.ps1 switch-env
.\scripts\gestlab-smart.ps1 restart
```

### Certificados SSL corruptos
```powershell
# Limpiar y regenerar certificados
Remove-Item -Recurse -Force "docker\nginx\ssl\*"
.\scripts\gestlab-smart.ps1 switch-env
.\scripts\gestlab-smart.ps1 restart
```

### Base de datos corrupta
```powershell
# Limpiar y reconstruir todo
.\scripts\gestlab-smart.ps1 clean
.\scripts\gestlab-smart.ps1 build
```

### Puerto ocupado
```powershell
# Ver qué procesos usan los puertos
netstat -ano | findstr "8000"
netstat -ano | findstr "8443"
netstat -ano | findstr "3307"
netstat -ano | findstr "8080"
```

## 📝 Credenciales por defecto

### Base de datos
- **Host**: gestlab-db (interno) / localhost:3307 (externo)
- **Usuario**: gestlab_user
- **Contraseña**: gestlab_password
- **Base de datos**: gestlab

### phpMyAdmin
- **URL Local**: <http://localhost:8080>
- **URL Prod**: <http://localhost:8080> (siempre HTTP)
- **Usuario**: gestlab_user
- **Contraseña**: gestlab_password

## ⚠️ Importante

1. **Docker Desktop** debe estar ejecutándose antes de usar los scripts
2. Los datos se persisten en `C:\gestlab-db` - **NO eliminar esta carpeta**
3. Para desarrollo, usar siempre `start/stop`, **NO** `clean`
4. El comando `clean` elimina TODOS los datos permanentemente
5. En modo **production**, los certificados SSL se generan automáticamente
6. El sistema detecta el entorno automáticamente desde `.env`

## 🔧 Migración desde versión anterior

Si vienes de la versión anterior (`gestlab-3containers.ps1`):

```powershell
# Detener contenedores antiguos
.\scripts\gestlab-3containers.ps1 stop

# Usar nuevo sistema
.\scripts\setup-gestlab.ps1
.\scripts\gestlab-smart.ps1 build
```

## 🎯 Ventajas de la nueva versión

- ✅ Detección automática de entorno (local/production)
- ✅ Configuración SSL automática en producción
- ✅ Cambio dinámico entre HTTP y HTTPS
- ✅ Headers de seguridad avanzada
- ✅ Configuración optimizada por entorno
- ✅ Certificados SSL autogenerados
- ✅ Gestión simplificada con un solo comando

## 📂 Estructura de contenedores

| Contenedor | Puerto | Función |
|------------|--------|---------|
| `gestlab-app` | 9000 | Aplicación Laravel (PHP-FPM) |
| `gestlab-nginx` | 8000 | Servidor web Nginx |
| `gestlab-db` | 3307 | Base de datos MySQL |
| `gestlab-phpmyadmin` | 8080 | Administrador de BD |

## 💾 Persistencia de datos

- **Base de datos**: `C:\gestlab-db\data`
- **Backups**: `C:\backup`
- **Logs**: `C:\gestlab-db\logs`

## 🔧 Comandos disponibles

```powershell
# Gestión completa
.\scripts\gestlab-3containers.ps1 build      # Construir todo desde cero
.\scripts\gestlab-3containers.ps1 start      # Iniciar todos los contenedores
.\scripts\gestlab-3containers.ps1 stop       # Detener todos los contenedores
.\scripts\gestlab-3containers.ps1 restart    # Reiniciar todos los contenedores
.\scripts\gestlab-3containers.ps1 status     # Ver estado y recursos
.\scripts\gestlab-3containers.ps1 logs       # Ver logs de todos los contenedores
.\scripts\gestlab-3containers.ps1 clean      # Limpiar todo (CUIDADO: elimina datos)

# Gestión individual
.\scripts\gestlab-3containers.ps1 start-db   # Solo base de datos
.\scripts\gestlab-3containers.ps1 stop-db    # Solo base de datos
.\scripts\gestlab-3containers.ps1 start-app  # Solo aplicación y nginx
.\scripts\gestlab-3containers.ps1 stop-app   # Solo aplicación y nginx
```

## 🆘 Solución de problemas

### Error 502 Bad Gateway
```powershell
# Reiniciar contenedores
.\scripts\gestlab-3containers.ps1 restart
```

### Base de datos corrupta
```powershell
# Limpiar y reconstruir todo
.\scripts\gestlab-3containers.ps1 clean
.\scripts\gestlab-3containers.ps1 build
```

### Puerto ocupado
```powershell
# Ver qué procesos usan los puertos
netstat -ano | findstr "8000"
netstat -ano | findstr "3307"
netstat -ano | findstr "8080"
```

## 📝 Credenciales por defecto

### Base de datos
- **Host**: gestlab-db (interno) / localhost:3307 (externo)
- **Usuario**: gestlab_user
- **Contraseña**: gestlab_password
- **Base de datos**: gestlab

### phpMyAdmin
- **URL**: http://localhost:8080
- **Usuario**: gestlab_user
- **Contraseña**: gestlab_password

## ⚠️ Importante

1. **Docker Desktop** debe estar ejecutándose antes de usar los scripts
2. Los datos se persisten en `C:\gestlab-db` - **NO eliminar esta carpeta**
3. Para desarrollo, usar siempre `start/stop`, **NO** `clean`
4. El comando `clean` elimina TODOS los datos permanentemente
