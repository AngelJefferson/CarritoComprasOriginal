# GUÍA PARA DOCKERIZAR EL PROYECTO CARRITO DE COMPRAS

## Requisitos Previos

1. **Docker Desktop** instalado en tu PC
2. **Git** instalado
3. **Visual Studio 2022** (para publicar)

---

## OPCIÓN 1: Proyecto Completo con SQL Server en Docker

### Estructura de Archivos

```
CarritoComprasDocker/
├── docker-compose.yml
├── Dockerfile
├── Admin/
│   └── (publicar desde Visual Studio)
├── Tienda/
│   └── (publicar desde Visual Studio)
└── Scripts/
    └── INSTALACION_COMPLETA.sql
```

### Paso 1: Publicar los Proyectos

1. En Visual Studio, click derecho en **CapaPresentacionAdmin**
2. Seleccionar **Publish**
3. Elegir **Folder** y publicar en `docker/Admin`
4. Repetir para **CapaPresentacionTienda** → `docker/Tienda`

### Paso 2: Crear Dockerfile para Admin

```dockerfile
# Admin
FROM mcr.microsoft.com/dotnet/aspnet:4.8 AS base
WORKDIR /inetpub/wwwroot
EXPOSE 44349

FROM mcr.microsoft.com/dotnet/sdk:4.8 AS build
WORKDIR /src
COPY ["Admin", "Admin"]
RUN dotnet restore "Admin/CapaPresentacionAdmin.csproj"
RUN dotnet build "Admin/CapaPresentacionAdmin.csproj" -c Release -o /Admin/build
RUN dotnet publish "Admin/CapaPresentacionAdmin.csproj" -c Release -o /Admin/publish

FROM base AS final
WORKDIR /inetpub/wwwroot
COPY --from=build /Admin/publish .
ENTRYPOINT ["dotnet", "CapaPresentacionAdmin.dll"]
```

### Paso 3: docker-compose.yml

```yaml
version: '3.8'

services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: carrito_sqlserver
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong@Passw0rd
      - MSSQL_PID=Developer
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql
      - ./Scripts:/docker-entrypoint-initdb.d
    networks:
      - carrito_network

  admin:
    build:
      context: .
      dockerfile: Dockerfile.Admin
    container_name: carrito_admin
    ports:
      - "5001:80"
      - "5002:443"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
    depends_on:
      - sqlserver
    networks:
      - carrito_network

  tienda:
    build:
      context: .
      dockerfile: Dockerfile.Tienda
    container_name: carrito_tienda
    ports:
      - "5003:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
    depends_on:
      - sqlserver
    networks:
      - carrito_network

  nginx:
    image: nginx:alpine
    container_name: carrito_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - admin
      - tienda
    networks:
      - carrito_network

volumes:
  sqlserver_data:

networks:
  carrito_network:
    driver: bridge
```

### Paso 4: Configurar nginx

```nginx
events {
    worker_connections 1024;
}

http {
    upstream admin_backend {
        server admin:80;
    }
    
    upstream tienda_backend {
        server tienda:80;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        # Panel Admin
        location /admin/ {
            proxy_pass http://admin_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        # Tienda
        location / {
            proxy_pass http://tienda_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

### Paso 5: Ejecutar

```bash
# En la terminal
cd CarritoComprasDocker
docker-compose up -d

# Ver logs
docker-compose logs -f

# Ver contenedores
docker-compose ps
```

---

## OPCIÓN 2: Deploy en Servicios en la Nube (Más Fácil)

### Opción A: Azure App Service (Recomendado)

1. **Publicar desde Visual Studio**
   - Click derecho en proyecto → Publish
   - Seleccionar **Azure** → **App Service**
   - Crear cuenta gratuita si no tienes

2. **Base de datos Azure SQL**
   - Crear Azure SQL Database en el portal de Azure
   - Copiar la cadena de conexión
   - Ejecutar `INSTALACION_COMPLETA.sql` en Azure

3. **Modificar Web.config**
   ```xml
   <connectionStrings>
     <add name="Conexion" 
          connectionString="Server=tuservidor.database.windows.net;Database=DBCARRITOTEST;User ID=tu_usuario;Password=tu_password;Trusted_Connection=False;Encrypt=True;" 
          providerName="System.Data.SqlClient"/>
   </connectionStrings>
   ```

### Opción B: Railway.app (Gratuito)

1. Crear proyecto en **railway.app**
2. Añadir plugin de PostgreSQL/MySQL
3. Subir proyecto desde GitHub
4. Configurar variables de entorno

### Opción C: Render.com (Gratuito)

1. Crear cuenta en render.com
2. Conectar desde GitHub
3. Añadir PostgreSQL database
4. Configurar build command y start command

---

## PASOS PARA SUBIR A UN SERVIDOR VPS

### 1. Instalar Docker en el VPS

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker
```

### 2. Copiar archivos al VPS

```bash
# Desde tu PC
scp -r CarritoComprasDocker user@tu_ip:/home/user/
```

### 3. Ejecutar en el VPS

```bash
ssh user@tu_ip
cd CarritoComprasDocker
docker-compose up -d
```

### 4. Configurar Firewall

```bash
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22
```

---

## CONFIGURACIÓN IMPORTANTE

### Modificar Web.config para Producción

En `CapaPresentacionAdmin/Web.config` y `CapaPresentacionTienda/Web.config`:

```xml
<configuration>
  <connectionStrings>
    <add name="Conexion" 
         connectionString="Server=sqlserver;Database=DBCARRITOTEST;User ID=sa;Password=YourStrong@Passw0rd;Integrated Security=False;" 
         providerName="System.Data.SqlClient"/>
  </connectionStrings>
</configuration>
```

### Para usar tu Base de Datos Externa

Si ya tienes una base de datos en la nube, solo modifica la cadena de conexión:

```xml
<add name="Conexion" 
     connectionString="Server=mi-servidor.database.windows.net;Database=DBCARRITOTEST;User Id=mi_usuario;Password=mi_password;Encrypt=True;TrustServerCertificate=False;" 
     providerName="System.Data.SqlClient"/>
```

---

## COMANDOS ÚTILES DE DOCKER

```bash
# Ver contenedores corriendo
docker ps

# Ver logs
docker logs -f nombre_contenedor

# Reiniciar servicio
docker-compose restart nombre_servicio

# Detener todo
docker-compose down

# Ver uso de recursos
docker stats

# Entrar al contenedor
docker exec -it nombre_contenedor bash

# Ver redes
docker network ls
```

---

## URLs de Acceso (según configuración)

- **Sitio principal (Tienda)**: http://tu-ip-o-dominio
- **Panel Admin**: http://tu-ip-o-dominio/admin/
- **phpMyAdmin** (si lo agregas): http://tu-ip-o-dominio:8080

---

## NOTA IMPORTANTE

Para que el proyecto funcione en Docker, necesitas:

1. ✅ Convertir a **.NET Core/.NET 6+** (el proyecto actual es .NET Framework 4.8)
2. O usar **Windows Containers** (más pesado y complejo)

El código actual usa **ASP.NET MVC con .NET Framework 4.8**, que requiere **Windows Containers**, los cuales necesitan Windows Server como host.

**Recomendación**: Migra a **ASP.NET Core** para mejor compatibilidad con Docker Linux.
