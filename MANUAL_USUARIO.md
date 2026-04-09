# MANUAL DE USUARIO - Carrito de Compras

## Tabla de Contenidos
1. [Introducción](#introducción)
2. [Acceso al Sistema](#acceso-al-sistema)
3. [Panel de Administración](#panel-de-administración)
4. [Tienda Online](#tienda-online)
5. [Proceso de Compra](#proceso-de-compra)
6. [Capturas de Pantalla](#capturas-de-pantalla)
7. [Glosario](#glosario)

---

## Introducción

El **Carrito de Compras** es un sistema de e-commerce desarrollado en ASP.NET MVC que permite:

- **Panel de Administración**: Gestionar productos, categorías, marcas y visualizar ventas
- **Tienda Online**: Navegar productos, registrarse, agregar al carrito y comprar

### Roles del Sistema

| Rol | Descripción | Acceso |
|-----|-------------|-------|
| Administrador | Gestiona el catálogo y ve reportes | Panel Admin |
| Cliente | Navega y compra productos | Tienda Online |

---

## Acceso al Sistema

### Panel de Administración

1. Abrir el navegador
2. Ir a: `https://localhost:44349/Acceso`
3. Ingresar credenciales:
   - **Usuario:** `admin`
   - **Contraseña:** `admin`
4. Click en "Ingresar"

**Nota:** La primera vez que accedas, el sistema te pedirá cambiar la contraseña.

### Tienda Online

1. Ir a: `http://localhost:44318/Acceso`
2. **Si ya tienes cuenta:** Iniciar sesión con correo y contraseña
3. **Si es nuevo:** Click en "Crear una cuenta" y completar el formulario

---

## Panel de Administración

### Dashboard (Inicio)

```
URL: https://localhost:44349/Home
```

Al iniciar sesión, verás el **Dashboard** con:
- Total de clientes registrados
- Total de ventas realizadas
- Total de productos en catálogo

**Funciones disponibles:**
- Ver reporte de ventas por fechas
- Acceder a gestión de productos

### Gestionar Productos

```
URL: https://localhost:44349/Mantenedor/Producto
```

#### Crear un Nuevo Producto

1. Click en "Nuevo Producto"
2. Llenar formulario:
   - **Nombre:** Nombre del producto
   - **Descripción:** Detalle del producto
   - **Marca:** Seleccionar de la lista
   - **Categoría:** Seleccionar de la lista
   - **Precio:** Precio en pesos dominicanos
   - **Stock:** Cantidad disponible
3. Click en "Guardar"

#### Editar un Producto

1. Buscar el producto en la lista
2. Click en el botón "Editar" (lápiz)
3. Modificar los campos deseados
4. Click en "Guardar"

#### Cambiar Imagen del Producto

1. En el producto, click en "Cambiar Imagen"
2. Seleccionar imagen del equipo (JPG, PNG)
3. Click en "Subir"

#### Activar/Desactivar Producto

1. En la lista, usar el toggle de "Activo/Inactivo"
2. Los productos inactivos no aparecen en la tienda

### Gestionar Marcas

```
URL: https://localhost:44349/Mantenedor/Marca
```

- **Crear:** Click en "Nueva Marca", escribir nombre, Guardar
- **Editar:** Click en icono de lápiz
- **Eliminar:** Click en icono de papelera (si no tiene productos asociados)

### Gestionar Categorías

```
URL: https://localhost:44349/Mantenedor/Categoria
```

- **Crear:** Click en "Nueva Categoria", escribir nombre, Guardar
- **Editar:** Click en icono de lápiz
- **Eliminar:** Click en icono de papelera (si no tiene productos asociados)

### Reporte de Ventas

```
URL: https://localhost:44349/Home (sección de reportes)
```

1. Seleccionar **fecha inicio** (ej: 01/03/2026)
2. Seleccionar **fecha fin** (ej: 09/04/2026)
3. Click en "Buscar"
4. Se mostrará lista de ventas con:
   - Fecha de venta
   - Cliente
   - Productos comprados
   - Monto total
   - ID de transacción

### Cambiar Contraseña

```
URL: https://localhost:44349/Acceso/CambiarClave
```

1. Ingresar contraseña actual
2. Ingresar nueva contraseña
3. Confirmar nueva contraseña
4. Click en "Cambiar"

### Cerrar Sesión

Click en "Cerrar Sesión" en el menú superior.

---

## Tienda Online

### Página Principal

```
URL: http://localhost:44318/Tienda
```

Muestra todos los productos disponibles con:
- Imagen del producto
- Nombre
- Precio
- Botón "Añadir al carrito"

### Buscar Productos

- Usar el **buscador** en la parte superior
- Escribir el nombre del producto
- Los resultados aparecen automáticamente

### Filtrar por Categoría

1. En el menú lateral, hacer clic en una **categoría**
2. Se mostrarán solo los productos de esa categoría

### Ver Detalle de Producto

1. Click en la imagen o nombre del producto
2. Se mostrará página con:
   - Imagen grande
   - Descripción completa
   - Precio
   - Stock disponible
   - Botón "Añadir al carrito"

---

## Proceso de Compra

### Paso 1: Registrarse (solo clientes nuevos)

1. Ir a `http://localhost:44318/Acceso`
2. Click en "Crear una cuenta"
3. Llenar formulario:
   - **Nombres:** Tu nombre
   - **Apellidos:** Tu apellido
   - **Correo:** Tu email (será tu usuario)
   - **Contraseña:** Mínimo 6 caracteres
   - **Provincia:** Seleccionar de la lista (República Dominicana)
4. Click en "Registrarse"

### Paso 2: Iniciar Sesión

1. Ir a `http://localhost:44318/Acceso`
2. Ingresar correo y contraseña
3. Click en "Ingresar"

### Paso 3: Navegar y Agregar al Carrito

1. Desde la tienda, buscar productos
2. En cada producto, click en **"Añadir al carrito"**
3. El carrito se actualiza en la esquina superior derecha

### Paso 4: Ver el Carrito

1. Click en el **carrito de compras** (esquina superior derecha)
2. Verificar productos agregados
3. **Modificar cantidad:** Cambiar número y click en "Actualizar"
4. **Eliminar producto:** Click en "X" junto al producto

### Paso 5: Completar Checkout

1. Desde el carrito, click en **"Completar compra"**
2. Llenar datos de envío:
   - **Nombres:** Nombre completo
   - **Teléfono:** Número de contacto
   - **Región:** Seleccionar departamento
   - **Provincia:** Seleccionar provincia
   - **Sector:** Seleccionar distrito/barrio
   - **Dirección:** Calle y número de casa
3. Click en **"Procesar pedido"**

### Paso 6: Confirmación

1. Recibirás un mensaje de confirmación
2. **Anotar el ID de transacción** (ej: `TRX-20260409-XXXX`)
3. Usa este ID para cualquier consulta

### Ejemplo Completo de Compra

```
Cliente: Juan Pérez
Correo: juan@email.com
Provincia: Santo Domingo Norte

Productos:
- Smart TV 55" - $599.99 x 1 = $599.99
- AirPods Pro - $249.99 x 2 = $499.98
- Total: $1,099.97

Dirección:
Región: Santo Domingo Norte
Provincia: Santo Domingo Norte
Sector: Villa Duarte
Dirección: Av. Marginal #123

ID Transacción: TRX-20260409-A1B2
```

---

## Capturas de Pantalla

### Pantalla 1: Login Administrador

```
┌─────────────────────────────────────────────────────────┐
│                    PANEL DE ADMINISTRACIÓN              │
│                    [Logo Carrito de Compras]            │
│                                                         │
│         ┌─────────────────────────────────────┐         │
│         │         INICIAR SESIÓN              │         │
│         │                                     │         │
│         │  Correo: [___________________]     │         │
│         │                                     │         │
│         │  Contraseña: [___________________] │         │
│         │                                     │         │
│         │  [        INGRESAR        ]         │         │
│         │                                     │         │
│         │  [¿Olvidaste tu contraseña?]        │         │
│         └─────────────────────────────────────┘         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Pantalla 2: Dashboard Admin

```
┌─────────────────────────────────────────────────────────┐
│  [Logo] Carrito Admin     Bienvenido: Admin    [Cerrar] │
├─────────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                │
│  │ CLIENTES │ │  VENTAS  │ │PRODUCTOS │                │
│  │    42    │ │   156    │ │    25    │                │
│  └──────────┘ └──────────┘ └──────────┘                │
│                                                         │
│  REPORTE DE VENTAS                                      │
│  Fecha inicio: [01/03/2026]                             │
│  Fecha fin:    [09/04/2026]                             │
│  ID Transacción: [______________]                       │
│  [                     BUSCAR                        ]  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │ Fecha │ Cliente      │ Transacción │ Total     │    │
│  ├───────┼──────────────┼─────────────┼───────────┤    │
│  │09/04  │ María García │ TRX-001...  │ $1,250.00│    │
│  │08/04  │ Carlos López │ TRX-002...  │ $599.99   │    │
│  │07/04  │ Ana Martínez │ TRX-003...  │ $899.50   │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
│  [Marcas] [Categorías] [Productos]                     │
└─────────────────────────────────────────────────────────┘
```

### Pantalla 3: Gestión de Productos

```
┌─────────────────────────────────────────────────────────┐
│  [Logo] Carrito Admin     Bienvenido: Admin    [Cerrar] │
├─────────────────────────────────────────────────────────┤
│  [Marcas] [Categorías] [Productos]                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  PRODUCTOS                           [+ Nuevo Producto] │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │ [Imagen] │ Nombre         │ Marca  │ Precio   │    │
│  ├──────────┼────────────────┼────────┼──────────┤    │
│  │ [📷 TV]  │ Smart TV 55"  │Samsung │ $599.99  │    │
│  │ [✏️] [🗑️] │ [📷] [Activo ✓]                    │    │
│  ├──────────┼────────────────┼────────┼──────────┤    │
│  │ [📷]     │ iPhone 15 Pro  │ Apple  │ $1,199.99│    │
│  │ [✏️] [🗑️] │ [📷] [Activo ✓]                    │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Pantalla 4: Login Tienda

```
┌─────────────────────────────────────────────────────────┐
│            🛒 TIENDA ONLINE                              │
│                                                         │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │   INICIAR SESIÓN │  │ CREAR CUENTA     │            │
│  │                  │  │                  │            │
│  │ Correo:          │  │ Nombres:         │            │
│  │ [______________] │  │ [______________] │            │
│  │                  │  │                  │            │
│  │ Contraseña:      │  │ Apellidos:      │            │
│  │ [______________] │  │ [______________] │            │
│  │                  │  │                  │            │
│  │ [   INGRESAR   ] │  │ Correo:         │            │
│  │                  │  │ [______________] │            │
│  │                  │  │                  │            │
│  │                  │  │ Contraseña:     │            │
│  │                  │  │ [______________] │            │
│  │                  │  │                  │            │
│  │                  │  │ Confirmar:       │            │
│  │                  │  │ [______________] │            │
│  │                  │  │                  │            │
│  │                  │  │ Provincia:       │            │
│  │                  │  │ [Santo Domingo ▼]│            │
│  │                  │  │                  │            │
│  │                  │  │ [  REGISTRARSE ]│            │
│  └──────────────────┘  └──────────────────┘            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Pantalla 5: Tienda Principal

```
┌─────────────────────────────────────────────────────────┐
│  🛒 Mi Tienda           [🔍 Buscar...]    [🛒 3] [👤]  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐             │
│  │ [📷]  │ │ [📷]  │ │ [📷]  │ │ [📷]  │             │
│  │       │ │       │ │       │ │       │             │
│  │SmartTV│ │iPhone │ │MacBook│ │AirPods│             │
│  │ $599  │ │$1,199 │ │$1,099 │ │ $249  │             │
│  │[🛒+1] │ │[🛒+1] │ │[🛒+1] │ │[🛒+1] │             │
│  └───────┘ └───────┘ └───────┘ └───────┘             │
│                                                         │
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐             │
│  │ [📷]  │ │ [📷]  │ │ [📷]  │ │ [📷]  │             │
│  │       │ │       │ │       │ │       │             │
│  │Samsung│ │Samsung│ │Sony   │ │LG     │             │
│  │S24    │ │Tab S9 │ │Audifon│ │TV OLED│             │
│  │ $1,099│ │ $799  │ │ $349  │ │$1,499  │             │
│  │[🛒+1] │ │[🛒+1] │ │[🛒+1] │ │[🛒+1] │             │
│  └───────┘ └───────┘ └───────┘ └───────┘             │
│                                                         │
│  Categorías: [Electrónica] [Telefonía] [Computadoras]  │
│              [Hogar] [Deportes] [Moda]                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Pantalla 6: Carrito de Compras

```
┌─────────────────────────────────────────────────────────┐
│  🛒 Mi Tienda           [🔍 Buscar...]    [🛒 3] [👤]  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│                    CARRITO DE COMPRAS                   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │ Producto           │ Precio  │ Cant │ Subtotal │    │
│  ├────────────────────┼─────────┼──────┼──────────┤    │
│  │ Smart TV 55"  [📷] │ $599.99 │ [2] │ $1,199.98│    │
│  │                              [Actualizar] [X]    │    │
│  ├────────────────────┼─────────┼──────┼──────────┤    │
│  │ AirPods Pro   [📷] │ $249.99 │ [1] │ $249.99  │    │
│  │                              [Actualizar] [X]    │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
│  Total: $1,449.97                                       │
│                                                         │
│  [              COMPLETAR COMPRA              ]         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Pantalla 7: Checkout

```
┌─────────────────────────────────────────────────────────┐
│  🛒 Mi Tienda           [🔍 Buscar...]    [🛒 3] [👤]  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│                    DATOS DE ENVÍO                       │
│                                                         │
│  Nombres: [Juan Pérez____________________________]       │
│  Teléfono: [8095551234________________________]        │
│                                                         │
│  Región:       [Santo Domingo Norte        ▼]            │
│  Provincia:    [Villa Mella                ▼]            │
│  Sector:       [Los Minas                 ▼]            │
│  Dirección:   [Av. Principal #123        ]            │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │ RESUMEN DEL PEDIDO                              │    │
│  │                                                 │    │
│  │ Smart TV 55" x 2         =        $1,199.98     │    │
│  │ AirPods Pro x 1          =          $249.99     │    │
│  │                                                 │    │
│  │ TOTAL                   =        $1,449.97      │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
│  [           PROCESAR PEDIDO              ]             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Pantalla 8: Confirmación de Compra

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                                                         │
│                    ✅ ¡GRACIAS POR TU COMPRA!          │
│                                                         │
│                                                         │
│  Tu pedido ha sido procesado exitosamente.              │
│                                                         │
│  ID de Transacción:                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │        TRX-20260409-A1B2C3D4                    │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  Resumen:                                               │
│  - Smart TV 55" x 2        =        $1,199.98         │
│  - AirPods Pro x 1         =          $249.99         │
│  - TOTAL                   =        $1,449.97         │
│                                                         │
│  Te contactaremos pronto para confirmar la entrega.     │
│                                                         │
│  [          SEGUIR COMPRANDO              ]             │
│                                                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Glosario

| Término | Definición |
|---------|------------|
| **Stock** | Cantidad disponible de un producto |
| **SKU** | Código único de identificación del producto |
| **Carrito** | Lista temporal de productos antes de comprar |
| **Checkout** | Proceso de completar la compra con datos de envío |
| **Transacción** | ID único que identifica una venta completada |
| **Dashboard** | Panel de estadísticas y resumen |
| **CRUD** | Create, Read, Update, Delete (Operaciones básicas) |
| **SKU** | Stock Keeping Unit - Código de producto |
| **SHA256** | Algoritmo de encriptación de contraseñas |
| **Provincia** | División geográfica de República Dominicana |
| **Sector** | División más pequeña (barrio/comunidad) |

---

## Preguntas Frecuentes

### ¿Olvidé mi contraseña de administrador?
Contactar al desarrollador del sistema para reiniciar la contraseña.

### ¿Puedo comprar sin registrarme?
No. Debes crear una cuenta para poder comprar.

### ¿Cómo sé que mi compra fue procesada?
Recibirás un ID de transacción. Guárdalo para cualquier consulta.

### ¿Puedo cancelar una compra?
Contactar al administrador antes de recibir el producto.

### ¿Los precios incluyen impuestos?
Los precios mostrados son finales. No hay cargos adicionales.

### ¿Hacen envíos a todo el país?
Sí, hacemos envíos a todas las provincias de República Dominicana.

---

**Versión del Documento:** 1.0  
**Fecha:** Abril 2026  
**Sistema:** Carrito de Compras ASP.NET MVC
