# MANUAL TÉCNICO - Carrito de Compras ASP.NET MVC

## Tabla de Contenidos
1. [Requisitos del Sistema](#requisitos-del-sistema)
2. [Instalación](#instalación)
3. [Configuración](#configuración)
4. [Arquitectura del Sistema](#arquitectura-del-sistema)
5. [Estructura del Proyecto](#estructura-del-proyecto)
6. [Base de Datos](#base-de-datos)
7. [Ejecución y Pruebas](#ejecución-y-pruebas)

---

## Requisitos del Sistema

### Software Necesario
- **Visual Studio 2022** o superior
- **SQL Server 2012** o superior (o SQL Server Express)
- **.NET Framework 4.7.2** o superior
- **SQL Server Management Studio (SSMS)** - Opcional pero recomendado

### Requisitos de Hardware
- Procesador: Intel Core i3 o superior
- RAM: 4 GB mínimo (8 GB recomendado)
- Espacio en disco: 500 MB mínimo
- Resolución de pantalla: 1366x768 o superior

---

## Instalación

### Paso 1: Clonar o Descargar el Proyecto

```bash
# Opción 1: Clonar desde GitHub
git clone https://github.com/AngelJefferson/CarritoComprasOriginal.git

# Opción 2: Descargar ZIP desde GitHub
# Ir a https://github.com/AngelJefferson/CarritoComprasOriginal
# Click en "Code" > "Download ZIP"
```

### Paso 2: Restaurar la Base de Datos

1. Abrir **SQL Server Management Studio (SSMS)**
2. Conectarse al servidor local `(localdb)\MSSQLLocalDB` o su servidor SQL
3. Abrir el archivo `Scripts/INSTALACION_COMPLETA.sql`
4. Ejecutar el script completo (F5 o click en "Execute")

```sql
-- El script crea:
-- - Base de datos: DBCARRITOTEST
-- - 11 tablas
-- - 29 procedimientos almacenados
-- - Datos iniciales (admin, marcas, categorías, productos)
```

### Paso 3: Abrir el Proyecto en Visual Studio

1. Abrir Visual Studio 2022
2. File > Open > Project/Solution
3. Navegar a la carpeta del proyecto
4. Abrir el archivo `.sln`

### Paso 4: Restaurar Paquetes NuGet

1. En Solution Explorer, click derecho en la solución
2. Seleccionar "Restore NuGet Packages"
3. Esperar a que se completen las descargas

### Paso 5: Compilar el Proyecto

1. Build > Build Solution (Ctrl+Shift+B)
2. Verificar que no haya errores de compilación

---

## Configuración

### Configuración de la Cadena de Conexión

El archivo de conexión se encuentra en cada proyecto de presentación:

**CapaPresentacionAdmin/Web.config**
**CapaPresentacionTienda/Web.config**

```xml
<connectionStrings>
    <add name="Conexion" 
         connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=DBCARRITOTEST;Integrated Security=True" 
         providerName="System.Data.SqlClient"/>
</connectionStrings>
```

### Parámetros de Conexión

| Parámetro | Descripción | Valor por Defecto |
|-----------|-------------|------------------|
| Data Source | Servidor SQL | `(localdb)\MSSQLLocalDB` |
| Initial Catalog | Nombre de la BD | `DBCARRITOTEST` |
| Integrated Security | Autenticación Windows | `True` |

### Para SQL Server Express o Remoto

```xml
<!-- SQL Server Express -->
<add name="Conexion" 
     connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=DBCARRITOTEST;Integrated Security=True" 
     providerName="System.Data.SqlClient"/>

<!-- Servidor Remoto -->
<add name="Conexion" 
     connectionString="Data Source=192.168.1.100;Initial Catalog=DBCARRITOTEST;User ID=sa;Password=tu_password" 
     providerName="System.Data.SqlClient"/>
```

### Dependencias y Librerías

**Paquetes NuGet utilizados:**

| Paquete | Versión | Descripción |
|---------|---------|-------------|
| Microsoft.AspNet.Mvc | 5.2.9 | Framework MVC para ASP.NET |
| Microsoft.AspNet.Razor | 3.2.9 | Motor de vistas Razor |
| Microsoft.AspNet.WebPages | 3.2.9 | Helpers web |
| Bootstrap | 5.3.x | Framework CSS para diseño responsive |
| jQuery | 3.7.x | Biblioteca JavaScript |
| System.Data.SqlClient | 4.8.x | Driver de SQL Server |

### Configuración de Puertos

El proyecto utiliza dos puertos diferentes:
- **Panel de Administración**: `https://localhost:44349`
- **Tienda**: `http://localhost:44318`

Para cambiar los puertos:
1. Click derecho en cada proyecto de presentación
2. Properties > Web
3. En "Servers", modificar el puerto

---

## Arquitectura del Sistema

### Patrón de Arquitectura: MVC (Model-View-Controller)

El proyecto sigue el patrón **MVC (Model-View-Controller)** con una arquitectura en capas:

```
┌─────────────────────────────────────────────────────────────┐
│                    CAPA PRESENTACIÓN                         │
│  ┌─────────────────────┐    ┌─────────────────────────┐    │
│  │ CapaPresentacion    │    │ CapaPresentacionTienda  │    │
│  │      Admin          │    │        (Tienda)          │    │
│  └─────────────────────┘    └─────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CAPA NEGOCIO                            │
│              CapaNegocio (Reglas de Negocio)                │
│  CN_Usuarios, CN_Producto, CN_Venta, CN_Cliente, etc.      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CAPA DATOS                              │
│               CapaDatos (Acceso a Datos)                    │
│  CD_Usuarios, CD_Producto, CD_Venta, CD_Cliente, etc.     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CAPA ENTIDAD                            │
│              CapaEntidad (Modelos de Datos)                 │
│  Usuario, Producto, Cliente, Venta, Marca, etc.            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    BASE DE DATOS                             │
│                    SQL Server                               │
│            DBCARRITOTEST (11 tablas, 29 SPs)               │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Datos

```
Usuario → Controlador → CapaNegocio → CapaDatos → Base de Datos
            ↓
         Vista (HTML/CSS/JS)
```

### Descripción de Capas

#### CapaEntidad
Contiene las clases que representan los objetos del dominio:
- `Usuario.cs` - Modelo de usuario administrador
- `Cliente.cs` - Modelo de cliente de tienda
- `Producto.cs` - Modelo de producto
- `Marca.cs`, `Categoria.cs` - Catálogos
- `Venta.cs`, `DetalleVenta.cs` - Órdenes de compra
- `Carrito.cs` - Carrito de compras

#### CapaDatos
Contiene las clases de acceso a datos (Data Access Layer):
- `CD_Usuarios.cs` - CRUD de usuarios
- `CD_Cliente.cs` - CRUD de clientes
- `CD_Producto.cs` - CRUD de productos
- `CD_Venta.cs` - Gestión de ventas
- `CD_Carrito.cs` - Gestión del carrito
- `CD_Marca.cs`, `CD_Categoria.cs` - Catálogos
- `CD_Ubicacion.cs` - Ubicaciones geográficas

#### CapaNegocio
Contiene la lógica de negocio (Business Logic Layer):
- `CN_Usuarios.cs` - Validaciones de usuario
- `CN_Cliente.cs` - Validaciones de cliente
- `CN_Producto.cs` - Validaciones de producto
- `CN_Venta.cs` - Lógica de venta
- `CN_Recursos.cs` - Utilidades (SHA256, correo)

#### CapaPresentacion
Contiene las vistas y controladores:
- **CapaPresentacionAdmin** - Panel de administración
- **CapaPresentacionTienda** - Tienda online para clientes

---

## Estructura del Proyecto

```
CarritoComprasOriginal/
│
├── CapaEntidad/
│   ├── Cliente.cs
│   ├── Usuario.cs
│   ├── Producto.cs
│   ├── Marca.cs
│   ├── Categoria.cs
│   ├── Venta.cs
│   ├── DetalleVenta.cs
│   ├── Carrito.cs
│   ├── Departamento.cs
│   ├── Provincia.cs
│   ├── Distrito.cs
│   ├── Reporte.cs
│   └── DashBoard.cs
│
├── CapaDatos/
│   ├── Conexion.cs          ← Cadena de conexión
│   ├── CD_Cliente.cs
│   ├── CD_Usuarios.cs
│   ├── CD_Producto.cs
│   ├── CD_Marca.cs
│   ├── CD_Categoria.cs
│   ├── CD_Venta.cs
│   ├── CD_Carrito.cs
│   ├── CD_Ubicacion.cs
│   └── CD_Reporte.cs
│
├── CapaNegocio/
│   ├── CN_Cliente.cs
│   ├── CN_Usuarios.cs
│   ├── CN_Producto.cs
│   ├── CN_Marca.cs
│   ├── CN_Categoria.cs
│   ├── CN_Venta.cs
│   ├── CN_Carrito.cs
│   ├── CN_Ubicacion.cs
│   ├── CN_Reporte.cs
│   └── CN_Recursos.cs      ← Utilidades (SHA256, correo)
│
├── CapaPresentacionAdmin/
│   ├── Controllers/
│   │   ├── AccesoController.cs    ← Login admin
│   │   ├── HomeController.cs      ← Dashboard
│   │   └── MantenedorController.cs ← CRUD productos
│   ├── Views/
│   │   ├── Acceso/                ← Login, cambiar clave
│   │   ├── Home/                  ← Dashboard
│   │   ├── Mantenedor/            ← Productos, categorías
│   │   └── Shared/                ← Layout principal
│   ├── Content/
│   │   └── Site.css               ← Estilos CSS
│   └── Web.config
│
├── CapaPresentacionTienda/
│   ├── Controllers/
│   │   ├── TiendaController.cs    ← Principal tienda
│   │   └── AccesoController.cs    ← Login/registro cliente
│   ├── Views/
│   │   ├── Tienda/               ← Inicio, producto, carrito
│   │   ├── Acceso/               ← Login, registro
│   │   └── Shared/               ← Layout tienda
│   └── Web.config
│
├── Scripts/
│   ├── INSTALACION_COMPLETA.sql  ← Script completo BD
│   └── PROCEDIMIENTOS_ALMACENADOS.sql ← 29 SPs
│
├── FOTO_CARRITO/                 ← Imágenes de productos
│
├── README.md
├── EXPLICACION_CODIGO.txt
└── MANUAL_TECNICO.md
```

---

## Base de Datos

### Esquema de Tablas

```
USUARIO ─────────────────┐
  │ IdUsuario (PK)       │
  │ Nombre               │
  │ Apellido             │
  │ Correo               │
  │ Clave (SHA256)       │
  │ Reestablecer         │
  │ Activo               │
  │ FechaRegistro        │
  └──────────────────────┘

CLIENTE ─────────────────┐
  │ IdCliente (PK)       │
  │ Nombres              │
  │ Apellidos            │
  │ Correo               │
  │ Clave (SHA256)       │
  │ Reestablecer         │
  │ Provincia            │
  │ FechaRegistro        │
  └──────────────────────┘
        │
        ├───────┬───────────┬────────────┐
        ▼       ▼           ▼            ▼
     CARRITO  VENTA    CARRITO      VENTA
     (IdCli)  (IdCli)  (IdCli)     (IdCli)

PRODUCTO ────────────────┐
  │ IdProducto (PK)     │───────┐
  │ Nombre              │       │
  │ Descripcion         │       │
  │ IdMarca (FK)────────┼───────┼───┐
  │ IdCategoria (FK)────┼───────┼───┼───┐
  │ Precio              │       │   │   │
  │ Stock               │       │   │   │
  │ RutaImagen          │       │   │   │
  │ NombreImagen        │       │   │   │
  │ Activo              │       │   │   │
  └─────────────────────┘       │   │   │
              ▲                 │   │   │
              │          ┌──────┘   │   │
              │          │  ┌──────┘   │
              │          ▼  ▼  ┌──────┘
    ┌─────────┴─┐  ┌─────┐  ┌──┴──┐
    │  CARRITO  │  │VENTA│  │DETALLE
    │ IdProducto │  │     │  │ VENTA
    └───────────┘  └─────┘  └──────┘
    
MARCA ────────────┐
  │ IdMarca (PK)  │
  │ Descripcion   │
  │ Activo        │
  └───────────────┘

CATEGORIA ──────────┐
  │ IdCategoria (PK)│
  │ Descripcion     │
  │ Activo          │
  └─────────────────┘

DEPARTAMENTO ──────┐
  │ IdDepartamento │
  │ Descripcion    │
  └────────────────┘
         │
         ▼
    PROVINCIA ──────────┐
      │ IdProvincia     │
      │ Descripcion     │
      │ IdDepartamento  │
      └─────────────────┘
             │
             ▼
        DISTRITO ─────────┐
          │ IdDistrito    │
          │ Descripcion   │
          │ IdProvincia   │
          │ IdDepartamento│
          └───────────────┘
```

### 29 Procedimientos Almacenados

| # | Procedimiento | Descripción |
|---|--------------|-------------|
| 1 | SP_RegistrarUsuario | Registrar nuevo usuario admin |
| 2 | SP_EditarUsuario | Editar datos de usuario |
| 3 | SP_EliminarUsuario | Eliminar usuario |
| 4 | SP_LoginCliente | Iniciar sesión cliente |
| 5 | SP_RegistrarCliente | Registrar nuevo cliente |
| 6 | SP_RegistrarMarca | Registrar marca |
| 7 | SP_EditarMarca | Editar marca |
| 8 | SP_EliminarMarca | Eliminar marca |
| 9 | SP_RegistrarCategoria | Registrar categoría |
| 10 | SP_EditarCategoria | Editar categoría |
| 11 | SP_EliminarCategoria | Eliminar categoría |
| 12 | SP_RegistrarProducto | Registrar producto |
| 13 | SP_EditarProducto | Editar producto |
| 14 | SP_EliminarProducto | Eliminar producto |
| 15 | SP_ListarProducto | Listar todos los productos |
| 16 | SP_ListarProductoTienda | Listar productos activos para tienda |
| 17 | SP_AgregarCarrito | Agregar producto al carrito |
| 18 | SP_ListarCarrito | Ver carrito del cliente |
| 19 | SP_ModificarCarrito | Modificar cantidad en carrito |
| 20 | SP_EliminarCarrito | Eliminar item del carrito |
| 21 | SP_ContarCarrito | Contar items en carrito |
| 22 | SP_LimpiarCarrito | Vaciar carrito |
| 23 | SP_ObtenerDepartamentos | Listar departamentos RD |
| 24 | SP_ObtenerProvincias | Listar provincias por departamento |
| 25 | SP_ObtenerDistritos | Listar distritos por provincia |
| 26 | SP_RegistrarVenta | Registrar venta con transacción |
| 27 | SP_ObtenerVenta | Obtener datos de una venta |
| 28 | SP_DetalleVenta | Obtener detalle de productos |
| 29 | SP_ReporteVentas | Reporte de ventas por fechas |
| 30 | SP_ReporteDashboard | Estadísticas del dashboard |

---

## Ejecución y Pruebas

### Ejecutar el Proyecto

#### Opción 1: Desde Visual Studio
1. Seleccionar el proyecto de inicio (CapaPresentacionAdmin o CapaPresentacionTienda)
2. Click en el botón verde "Play" o presionar F5
3. Se abrirá el navegador con la aplicación

#### Opción 2: Múltiples proyectos
Para ejecutar ambos simultáneamente:
1. Click derecho en la solución
2. Properties > Startup Project
3. Seleccionar "Multiple startup projects"
4. Asignar "Start" a ambos proyectos de presentación

### Credenciales de Prueba

**Panel de Administración:**
- Usuario: `admin`
- Contraseña: `admin`
- URL: `https://localhost:44349/Acceso`

**Tienda (registro nuevo):**
- Registro libre en `http://localhost:44318/Acceso`

### Probar Funcionalidades

#### 1. Login de Administrador
```
URL: https://localhost:44349/Acceso
Usuario: admin
Contraseña: admin
```
Primera vez: Pedirá cambiar la contraseña.

#### 2. Gestionar Productos
```
URL: https://localhost:44349/Mantenedor/Producto
- Crear nuevo producto
- Editar producto existente
- Cambiar imagen
- Activar/Desactivar
```

#### 3. Registro de Cliente en Tienda
```
URL: http://localhost:44318/Acceso
- Llenar formulario de registro
- Seleccionar provincia de RD
- Iniciar sesión
```

#### 4. Proceso de Compra
```
1. Navegar productos en tienda
2. Agregar al carrito
3. Ir al carrito
4. Completar datos de envío
5. Confirmar compra
6. Recibir ID de transacción
```

### Solución de Problemas Comunes

#### Error: "Cannot open database DBCARRITOTEST"
```
Solución:
1. Verificar que SQL Server esté ejecutándose
2. Ejecutar el script INSTALACION_COMPLETA.sql
3. Verificar la cadena de conexión en Web.config
```

#### Error: "Login failed" en SQL
```
Solución:
1. Verificar autenticación de Windows en la conexión
2. O cambiar a autenticación SQL con usuario/contraseña
```

#### Error de compilación de paquetes NuGet
```
Solución:
1. Tools > NuGet Package Manager > Package Manager Console
2. Ejecutar: Update-Package -Reinstall
```

#### Página en blanco después de login
```
Solución:
1. Verificar que Session["Usuario"] o Session["Cliente"] esté configurado
2. Limpiar cache del navegador
3. Verificar que las vistas existan en la ubicación correcta
```

---

## Mantenimiento

### Respaldar la Base de Datos
```sql
BACKUP DATABASE DBCARRITOTEST 
TO DISK = 'C:\Respaldos\DBCARRITOTEST.bak' 
WITH COMPRESSION;
```

### Restaurar la Base de Datos
```sql
RESTORE DATABASE DBCARRITOTEST 
FROM DISK = 'C:\Respaldos\DBCARRITOTEST.bak' 
WITH REPLACE;
```

### Reiniciar Datos de Prueba
Ejecutar nuevamente el script `INSTALACION_COMPLETA.sql`

---

**Versión del Documento:** 1.0  
**Fecha:** Abril 2026  
**Autor:** Proyecto Carrito de Compras ASP.NET MVC
