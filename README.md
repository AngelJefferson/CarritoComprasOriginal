🛒 CarritoCompras
👨‍💻 Información del Autor

Angel Jefferson Sanchez Ventura
Estudiante del Instituto Tecnológico de Las Américas (ITLA)
Matrícula: 2021-1816

📖 Descripción del Proyecto

CarritoCompras es un sistema web desarrollado bajo el patrón ASP.NET MVC, implementando una arquitectura en capas para garantizar una adecuada separación de responsabilidades.

El sistema está orientado a la gestión de una tienda virtual, permitiendo:

Administración de usuarios

Gestión de categorías y marcas

Gestión de productos

Simulación de carrito de compras

Registro de ventas

La arquitectura aplicada facilita la escalabilidad, mantenimiento y organización estructurada del código fuente.

🏗️ Arquitectura del Proyecto

La solución está organizada bajo el principio de Separation of Concerns, dividiendo el sistema en las siguientes capas:

🔹 CapaDatos

Encargada del acceso a datos mediante ADO.NET, gestionando la conexión y ejecución de procedimientos almacenados en SQL Server.

🔹 CapaEntidad

Contiene las entidades del sistema que representan las tablas de la base de datos.

🔹 CapaNegocio

Implementa la lógica de negocio y reglas del sistema, actuando como intermediaria entre la presentación y los datos.

🔹 CapaPresentacionAdmin

Interfaz web administrativa para la gestión interna del sistema.

🔹 CapaPresentacionTienda

Interfaz web orientada al cliente final (tienda virtual).

🛠️ Tecnologías Utilizadas

ASP.NET MVC

C#

ADO.NET

SQL Server

Bootstrap

JavaScript

Arquitectura en capas

Plantilla utilizada:
Aplicación web ASP.NET Core

⚙️ Requisitos del Sistema

Para ejecutar el proyecto en otra computadora se requiere:

Visual Studio 2019 o superior

SQL Server (Express o superior)

SQL Server Management Studio (SSMS)

Git (opcional, para clonar el repositorio)

🚀 Instalación y Ejecución
**Clonar el Repositorio**
git clone https://github.com/AngelJefferson/CarritoCompras.git
**Abrir la Solución**

Abrir el archivo:

CarritoCompras.sln

Desde Visual Studio.

Si es necesario:

Click derecho sobre la solución

Seleccionar Restore NuGet Packages

**Configuración de la Base de Datos**

Abrir SQL Server Management Studio.

Crear una base de datos llamada:

DBCARRITO

Ejecutar el script CarritoCompras.sql incluido en el proyecto para generar:

Tablas

Relaciones

Llaves foráneas

Procedimientos almacenados

El script crea automáticamente todas las estructuras necesarias del sistema, incluyendo:

USUARIO

CLIENTE

PRODUCTO

CATEGORIA

MARCA

VENTA

DETALLE_VENTA

CARRITO

Y los procedimientos almacenados:

sp_RegistrarUsuario

sp_EditarUsuario

** Configurar la Cadena de Conexión**

Abrir el archivo:

Web.config

Ubicar la sección:

<connectionStrings>

Ejemplo de configuración con autenticación integrada:

Data Source=localhost;
Initial Catalog=DBCARRITO;
Integrated Security=True;

** Ejecutar el Proyecto**

Establecer CapaPresentacionAdmin como proyecto de inicio.

Presionar F5 o el botón Ejecutar.

El sistema se abrirá automáticamente en el navegador.

🔐 Seguridad

Las contraseñas de los usuarios no se almacenan en texto plano.
El sistema implementa un mecanismo de encriptación desde la CapaNegocio, garantizando mayor seguridad en el almacenamiento de credenciales.

📌 Estado Actual del Proyecto

Proyecto en fase inicial de desarrollo académico.

Actualmente se encuentra funcional el módulo de Gestión de Usuarios, permitiendo:

Registrar usuarios

Editar usuarios

Eliminar usuarios

Filtrar usuarios

Validación de correos duplicados

La conexión con la base de datos se encuentra operativa y estable.
# CarritoComprasTest
# CarritoComprasTest

---

# GUIA DE INSTALACION - NUEVA INSTALACION

## Paso 1: Ejecutar Script SQL

1. Abre SQL Server Management Studio (SSMS)
2. Conectate a tu servidor SQL
3. Abre el archivo: `Scripts/INSTALACION.sql`
4. Ejecuta todo el script (F5)

## Paso 2: Configurar Cadena de Conexion

Edita los Web.config de ambos proyectos:

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

## Paso 3: Ejecutar el Proyecto

1. En Visual Studio, clic derecho en la solucion
2. Selecciona "Establecer proyectos de inicio"
3. Cambia a "Varios proyectos de inicio"
4. Marca "Iniciar" para ambos proyectos
5. Presiona F5

## Datos de Acceso

**Panel Admin:** https://localhost:44349/
- Correo: admin@carrito.com
- Clave: admin123

**Tienda:** http://localhost:44318/
