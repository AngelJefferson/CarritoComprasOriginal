# 🛒 CarritoComprasOriginal

Sistema de tienda virtual desarrollado en ASP.NET MVC con arquitectura en capas.

## 👨‍💻 Información del Autor

**Angel Jefferson Sanchez Ventura**
- Estudiante del Instituto Tecnológico de Las Américas (ITLA)
- Matrícula: 2021-1816

---

## 📖 Descripción

CarritoCompras es un sistema web completo de e-commerce que permite:

- **Panel de Administración**: Gestión de usuarios, productos, categorías y marcas
- **Tienda Virtual**: Catálogo de productos, carrito de compras y proceso de compra
- **Registro de Clientes**: Con selección de provincia (República Dominicana)
- **Recuperación de Contraseña**: Sistema de reestablecimiento por correo

---

## 🏗️ Arquitectura del Proyecto

El proyecto utiliza arquitectura en capas (Layered Architecture):

```
CarritoComprasOriginal/
├── CapaEntidad/           → Entidades y modelos de datos
├── CapaDatos/             → Acceso a base de datos (ADO.NET)
├── CapaNegocio/           → Lógica de negocio
├── CapaPresentacionAdmin/ → Panel de administración
├── CapaPresentacionTienda/ → Tienda online
├── Scripts/               → Scripts SQL de instalación
└── FOTO_CARRITO/         → Carpeta para imágenes de productos
```

---

## 🛠️ Tecnologías Utilizadas

- **ASP.NET MVC 5** - Framework web
- **C#** - Lenguaje de programación
- **SQL Server** - Base de datos
- **ADO.NET** - Acceso a datos
- **Bootstrap 5** - Framework CSS
- **DataTables** - Tablas interactivas
- **jQuery** - Manipulación del DOM
- **Font Awesome** - Iconos

---

## ⚙️ Requisitos del Sistema

- Visual Studio 2019 o superior
- SQL Server (LocalDB, Express o Standard)
- SQL Server Management Studio (SSMS)
- .NET Framework 4.7.2

---

## 🚀 Instalación

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/AngelJefferson/CarritoComprasOriginal.git
```

### Paso 2: Configurar la Base de Datos

1. Abre SQL Server Management Studio (SSMS)
2. Conecta a tu servidor SQL
3. Abre el archivo: `Scripts/INSTALACION.sql`
4. Ejecuta todo el script (F5)

Esto creará:
- Base de datos `DBCARRITOTEST`
- Todas las tablas necesarias
- Procedimientos almacenados
- Datos iniciales (usuario admin, productos de ejemplo)

### Paso 3: Configurar Cadena de Conexión

Edita los archivos Web.config de ambos proyectos:

**CapaPresentacionAdmin/Web.config:**
```xml
<add name="cadena" connectionString="Data Source=TU_SERVIDOR;Initial Catalog=DBCARRITOTEST;Integrated Security=True" providerName="System.Data.SqlClient"/>
```

**CapaPresentacionTienda/Web.config:**
```xml
<add name="cadena" connectionString="Data Source=TU_SERVIDOR;Initial Catalog=DBCARRITOTEST;Integrated Security=True" providerName="System.Data.SqlClient"/>
```

Reemplaza `TU_SERVIDOR` con:
- `(localdb)\MSSQLLocalDB` - para LocalDB
- `localhost` - para SQL Server local
- `.\SQLEXPRESS` - para SQL Server Express

### Paso 4: Ejecutar el Proyecto

**Opción A: Varios proyectos de inicio**
1. Clic derecho en la solución
2. Selecciona "Establecer proyectos de inicio"
3. Cambia a "Varios proyectos de inicio"
4. Marca "Iniciar" para ambos proyectos
5. Presiona F5

**Opción B: Ejecutar por separado**
1. Ejecuta primero CapaPresentacionAdmin (F5)
2. Luego ejecuta CapaPresentacionTienda (F5)

---

## 🔐 Datos de Acceso

### Panel de Administración
- **URL:** `https://localhost:44349/`
- **Correo:** `admin@carrito.com`
- **Contraseña:** `admin123`

### Tienda Online
- **URL:** `http://localhost:44318/`

---

## 📦 Funcionalidades

### Panel de Administración
- ✅ Dashboard con estadísticas
- ✅ Gestión de usuarios (crear, editar, eliminar)
- ✅ Gestión de categorías
- ✅ Gestión de marcas
- ✅ Gestión de productos (con imágenes)
- ✅ Recuperación de contraseña
- ✅ Cambio obligatorio de contraseña al primer inicio
- ✅ Exportar ventas a Excel

### Tienda Online
- ✅ Catálogo de productos con imágenes
- ✅ Filtrar por categoría
- ✅ Buscar productos
- ✅ Registro de clientes con provincia
- ✅ Carrito de compras
- ✅ Proceso de compra (checkout)
- ✅ Confirmación de pedido

---

## 🔒 Seguridad

- Las contraseñas se encriptan con SHA256
- Sistema de reestablecimiento de contraseña
- Validación de datos en todas las capas

---

## 📁 Estructura de la Base de Datos

### Tablas Principales
- **USUARIO** - Usuarios del panel admin
- **CLIENTE** - Clientes de la tienda
- **PRODUCTO** - Productos con imágenes
- **CATEGORIA** - Categorías de productos
- **MARCA** - Marcas de productos
- **CARRITO** - Carrito de compras
- **VENTA** - Registro de ventas
- **DETALLE_VENTA** - Detalles de cada venta
- **DEPARTAMENTO** - Ubicaciones (RD)
- **PROVINCIA** - Provincias de República Dominicana
- **DISTRITO** - Distritos/Sectores

---

## 📄 Documentación Adicional

- `EXPLICACION_CODIGO.txt` - Explicación detallada del código
- `Scripts/INSTALACION.sql` - Script para crear la base de datos

---

## 📌 Notas

- El proyecto usa imágenes de internet como respaldo cuando no hay imágenes locales
- La carpeta `FOTO_CARRITO` es para almacenar imágenes de productos
- Los productos de ejemplo incluyen Electronics, Computers, Phones, Home, Sports, Fashion, etc.

---

## 📧 Contacto

¿Preguntas o sugerencias? Contáctame a través de GitHub.

---

**Desarrollado por:** Angel Jefferson Sanchez Ventura
**Año:** 2026
