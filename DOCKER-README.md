# GestLab - Configuración Docker en Windows

## 🚀 Configuración inicial (solo una vez)

```powershell
# 1. Configurar el entorno
.\scripts\setup-windows.ps1

# 2. Construir e iniciar todos los contenedores
.\scripts\gestlab-3containers.ps1 build
```

## 📋 Uso diario

### Iniciar la aplicación
```powershell
.\scripts\gestlab-3containers.ps1 start
```

### Detener la aplicación
```powershell
.\scripts\gestlab-3containers.ps1 stop
```

### Ver estado de contenedores
```powershell
.\scripts\gestlab-3containers.ps1 status
```

### Ver logs en tiempo real
```powershell
.\scripts\gestlab-3containers.ps1 logs
```

## 🔗 Enlaces importantes

- **Aplicación Laravel**: http://localhost:8000
- **phpMyAdmin**: http://localhost:8080
- **Base de datos MySQL**: localhost:3307

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
