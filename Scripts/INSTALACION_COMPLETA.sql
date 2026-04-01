-- ================================================================
-- SCRIPT DE INSTALACIÓN COMPLETA - CARRITO DE COMPRAS
-- Ejecutar en SQL Server Management Studio
-- ================================================================
-- Compatible con: SQL Server 2012 en adelante
-- Una vez ejecutado, el proyecto estará listo para funcionar
-- ================================================================

USE master;
GO

-- ================================================================
-- PARTE 1: CREAR BASE DE DATOS
-- ================================================================
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DBCARRITOTEST')
BEGIN
    ALTER DATABASE DBCARRITOTEST SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBCARRITOTEST;
END
CREATE DATABASE DBCARRITOTEST;
PRINT 'Base de datos DBCARRITOTEST creada';
GO

USE DBCARRITOTEST;
GO

-- ================================================================
-- PARTE 2: CREAR TABLAS
-- ================================================================

-- Tabla MARCA
CREATE TABLE MARCA(
    IdMarca int identity(1,1) primary key,
    Descripcion varchar(100),
    Activo bit default 1
);
PRINT 'Tabla MARCA creada';

-- Tabla CATEGORIA
CREATE TABLE CATEGORIA(
    IdCategoria int identity(1,1) primary key,
    Descripcion varchar(100),
    Activo bit default 1
);
PRINT 'Tabla CATEGORIA creada';

-- Tabla USUARIO
CREATE TABLE USUARIO(
    IdUsuario int identity(1,1) primary key,
    Nombre varchar(100),
    Apellido varchar(100),
    Correo varchar(100),
    Clave varchar(150),
    Reestablecer bit default 0,
    Activo bit default 1,
    FechaRegistro datetime default getdate()
);
PRINT 'Tabla USUARIO creada';

-- Tabla CLIENTE
CREATE TABLE CLIENTE(
    IdCliente int identity(1,1) primary key,
    Nombres varchar(100),
    Apellidos varchar(100),
    Correo varchar(100),
    Clave varchar(150),
    Reestablecer bit default 0,
    FechaRegistro datetime default getdate(),
    Provincia varchar(100) NULL
);
PRINT 'Tabla CLIENTE creada';

-- Tabla DEPARTAMENTO
CREATE TABLE DEPARTAMENTO(
    IdDepartamento varchar(5) primary key,
    Descripcion varchar(100)
);
PRINT 'Tabla DEPARTAMENTO creada';

-- Tabla PROVINCIA
CREATE TABLE PROVINCIA(
    IdProvincia varchar(5) primary key,
    Descripcion varchar(100),
    IdDepartamento varchar(5) references DEPARTAMENTO(IdDepartamento)
);
PRINT 'Tabla PROVINCIA creada';

-- Tabla DISTRITO
CREATE TABLE DISTRITO(
    IdDistrito varchar(10) primary key,
    Descripcion varchar(100),
    IdProvincia varchar(5) references PROVINCIA(IdProvincia),
    IdDepartamento varchar(5) references DEPARTAMENTO(IdDepartamento)
);
PRINT 'Tabla DISTRITO creada';

-- Tabla PRODUCTO
CREATE TABLE PRODUCTO(
    IdProducto int identity(1,1) primary key,
    Nombre varchar(500),
    Descripcion varchar(500),
    IdMarca int references MARCA(IdMarca),
    IdCategoria int references CATEGORIA(IdCategoria),
    Precio decimal(10,2) default 0,
    Stock int,
    RutaImagen varchar(100),
    NombreImagen varchar(100),
    Activo bit default 1,
    FechaRegistro datetime default getdate()
);
PRINT 'Tabla PRODUCTO creada';

-- Tabla CARRITO
CREATE TABLE CARRITO(
    IdCarrito int identity(1,1) primary key,
    IdCliente int references CLIENTE(IdCliente),
    IdProducto int references PRODUCTO(IdProducto),
    Cantidad int
);
PRINT 'Tabla CARRITO creada';

-- Tabla VENTA
CREATE TABLE VENTA(
    IdVenta int identity(1,1) primary key,
    IdCliente int references CLIENTE(IdCliente),
    TotalProducto int,
    MontoTotal decimal(10,2),
    Contacto varchar(50),
    Telefono varchar(50),
    IdDistrito varchar(10) references DISTRITO(IdDistrito),
    Direccion varchar(500),
    IdTransaccion varchar(50),
    FechaVenta datetime default getdate()
);
PRINT 'Tabla VENTA creada';

-- Tabla DETALLE_VENTA
CREATE TABLE DETALLE_VENTA(
    IdDetalleVenta int identity(1,1) primary key,
    IdVenta int references VENTA(IdVenta),
    IdProducto int references PRODUCTO(IdProducto),
    Cantidad int,
    Total decimal(10,2)
);
PRINT 'Tabla DETALLE_VENTA creada';

PRINT '';
PRINT '============================================';
PRINT ' TODAS LAS TABLAS CREADAS';
PRINT '============================================';
GO

-- ================================================================
-- PARTE 3: CREAR STORED PROCEDURES - USUARIOS
-- ================================================================

-- SP Registrar Usuario
IF OBJECT_ID('SP_RegistrarUsuario', 'P') IS NOT NULL DROP PROCEDURE SP_RegistrarUsuario;
GO
CREATE PROCEDURE SP_RegistrarUsuario
    @Nombres varchar(100), @Apellidos varchar(100), @Correo varchar(100),
    @Clave varchar(150), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM USUARIO WHERE Correo = @Correo)
    BEGIN
        INSERT INTO USUARIO(Nombre, Apellido, Correo, Clave, Reestablecer, Activo)
        VALUES (@Nombres, @Apellidos, @Correo, @Clave, 1, @Activo)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE BEGIN
        SET @Mensaje = 'El correo ya existe'
    END
END
GO
PRINT 'SP_RegistrarUsuario creado';

-- SP Editar Usuario
IF OBJECT_ID('SP_EditarUsuario', 'P') IS NOT NULL DROP PROCEDURE SP_EditarUsuario;
GO
CREATE PROCEDURE SP_EditarUsuario
    @IdUsuario int, @Nombres varchar(100), @Apellidos varchar(100),
    @Correo varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM USUARIO WHERE Correo = @Correo AND IdUsuario != @IdUsuario)
    BEGIN
        UPDATE USUARIO SET Nombre = @Nombres, Apellido = @Apellidos, Correo = @Correo, Activo = @Activo WHERE IdUsuario = @IdUsuario
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'El correo ya existe en otro usuario'
    END
END
GO
PRINT 'SP_EditarUsuario creado';

-- SP Eliminar Usuario
IF OBJECT_ID('SP_EliminarUsuario', 'P') IS NOT NULL DROP PROCEDURE SP_EliminarUsuario;
GO
CREATE PROCEDURE SP_EliminarUsuario
    @IdUsuario int,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM VENTA WHERE IdCliente = @IdUsuario)
    BEGIN
        DELETE FROM USUARIO WHERE IdUsuario = @IdUsuario
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'El usuario tiene ventas registradas, no se puede eliminar'
    END
END
GO
PRINT 'SP_EliminarUsuario creado';

-- SP Login Usuario
IF OBJECT_ID('SP_LoginUsuario', 'P') IS NOT NULL DROP PROCEDURE SP_LoginUsuario;
GO
CREATE PROCEDURE SP_LoginUsuario
    @Correo varchar(100), @Clave varchar(150),
    @Resultado int OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    IF EXISTS (SELECT IdUsuario FROM USUARIO WHERE Correo = @Correo AND Clave = @Clave AND Activo = 1)
    BEGIN
        SELECT @Resultado = IdUsuario FROM USUARIO WHERE Correo = @Correo AND Clave = @Clave
    END ELSE BEGIN
        SET @Mensaje = 'El correo o la clave no coinciden'
    END
END
GO
PRINT 'SP_LoginUsuario creado';

-- SP Reestablecer Clave
IF OBJECT_ID('SP_ReestablecerClave', 'P') IS NOT NULL DROP PROCEDURE SP_ReestablecerClave;
GO
CREATE PROCEDURE SP_ReestablecerClave
    @Correo varchar(100),
    @Resultado int OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    DECLARE @NuevaClave varchar(150) = LEFT(CONVERT(varchar(36), NEWID()), 8)
    DECLARE @IdUsuario int
    SELECT @IdUsuario = IdUsuario FROM USUARIO WHERE Correo = @Correo AND Activo = 1
    IF @IdUsuario > 0
    BEGIN
        UPDATE USUARIO SET Clave = @NuevaClave, Reestablecer = 1 WHERE IdUsuario = @IdUsuario
        SET @Resultado = @IdUsuario
        SET @Mensaje = @NuevaClave
    END ELSE BEGIN
        SET @Mensaje = 'No se encontro un usuario con ese correo'
    END
END
GO
PRINT 'SP_ReestablecerClave creado';

-- ================================================================
-- PARTE 4: STORED PROCEDURES - MARCAS
-- ================================================================

-- SP Registrar Marca
IF OBJECT_ID('SP_RegistrarMarca', 'P') IS NOT NULL DROP PROCEDURE SP_RegistrarMarca;
GO
CREATE PROCEDURE SP_RegistrarMarca
    @Descripcion varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM MARCA WHERE Descripcion = @Descripcion)
    BEGIN
        INSERT INTO MARCA(Descripcion, Activo) VALUES (@Descripcion, @Activo)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE BEGIN
        SET @Mensaje = 'La marca ya existe'
    END
END
GO
PRINT 'SP_RegistrarMarca creado';

-- SP Editar Marca
IF OBJECT_ID('SP_EditarMarca', 'P') IS NOT NULL DROP PROCEDURE SP_EditarMarca;
GO
CREATE PROCEDURE SP_EditarMarca
    @IdMarca int, @Descripcion varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM MARCA WHERE Descripcion = @Descripcion AND IdMarca != @IdMarca)
    BEGIN
        UPDATE MARCA SET Descripcion = @Descripcion, Activo = @Activo WHERE IdMarca = @IdMarca
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'La marca ya existe'
    END
END
GO
PRINT 'SP_EditarMarca creado';

-- SP Eliminar Marca
IF OBJECT_ID('SP_EliminarMarca', 'P') IS NOT NULL DROP PROCEDURE SP_EliminarMarca;
GO
CREATE PROCEDURE SP_EliminarMarca
    @IdMarca int,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE IdMarca = @IdMarca)
    BEGIN
        DELETE FROM MARCA WHERE IdMarca = @IdMarca
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'La marca tiene productos asociados'
    END
END
GO
PRINT 'SP_EliminarMarca creado';

-- ================================================================
-- PARTE 5: STORED PROCEDURES - CATEGORIAS
-- ================================================================

-- SP Registrar Categoria
IF OBJECT_ID('SP_RegistrarCategoria', 'P') IS NOT NULL DROP PROCEDURE SP_RegistrarCategoria;
GO
CREATE PROCEDURE SP_RegistrarCategoria
    @Descripcion varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion = @Descripcion)
    BEGIN
        INSERT INTO CATEGORIA(Descripcion, Activo) VALUES (@Descripcion, @Activo)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE BEGIN
        SET @Mensaje = 'La categoria ya existe'
    END
END
GO
PRINT 'SP_RegistrarCategoria creado';

-- SP Editar Categoria
IF OBJECT_ID('SP_EditarCategoria', 'P') IS NOT NULL DROP PROCEDURE SP_EditarCategoria;
GO
CREATE PROCEDURE SP_EditarCategoria
    @IdCategoria int, @Descripcion varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion = @Descripcion AND IdCategoria != @IdCategoria)
    BEGIN
        UPDATE CATEGORIA SET Descripcion = @Descripcion, Activo = @Activo WHERE IdCategoria = @IdCategoria
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'La categoria ya existe'
    END
END
GO
PRINT 'SP_EditarCategoria creado';

-- SP Eliminar Categoria
IF OBJECT_ID('SP_EliminarCategoria', 'P') IS NOT NULL DROP PROCEDURE SP_EliminarCategoria;
GO
CREATE PROCEDURE SP_EliminarCategoria
    @IdCategoria int,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE IdCategoria = @IdCategoria)
    BEGIN
        DELETE FROM CATEGORIA WHERE IdCategoria = @IdCategoria
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'La categoria tiene productos asociados'
    END
END
GO
PRINT 'SP_EliminarCategoria creado';

-- ================================================================
-- PARTE 6: STORED PROCEDURES - PRODUCTOS
-- ================================================================

-- SP Registrar Producto
IF OBJECT_ID('SP_RegistrarProducto', 'P') IS NOT NULL DROP PROCEDURE SP_RegistrarProducto;
GO
CREATE PROCEDURE SP_RegistrarProducto
    @Nombre varchar(500), @Descripcion varchar(500), @IdMarca int,
    @IdCategoria int, @Precio decimal(10,2), @Stock int, @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
AS BEGIN
    SET @Resultado = 0
    INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, Activo)
    VALUES (@Nombre, @Descripcion, @IdMarca, @IdCategoria, @Precio, @Stock, @Activo)
    SET @Resultado = SCOPE_IDENTITY()
END
GO
PRINT 'SP_RegistrarProducto creado';

-- SP Editar Producto
IF OBJECT_ID('SP_EditarProducto', 'P') IS NOT NULL DROP PROCEDURE SP_EditarProducto;
GO
CREATE PROCEDURE SP_EditarProducto
    @IdProducto int, @Nombre varchar(500), @Descripcion varchar(500),
    @IdMarca int, @IdCategoria int, @Precio decimal(10,2), @Stock int, @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 0
    UPDATE PRODUCTO SET Nombre = @Nombre, Descripcion = @Descripcion, IdMarca = @IdMarca,
        IdCategoria = @IdCategoria, Precio = @Precio, Stock = @Stock, Activo = @Activo
    WHERE IdProducto = @IdProducto
    SET @Resultado = 1
END
GO
PRINT 'SP_EditarProducto creado';

-- SP Eliminar Producto
IF OBJECT_ID('SP_EliminarProducto', 'P') IS NOT NULL DROP PROCEDURE SP_EliminarProducto;
GO
CREATE PROCEDURE SP_EliminarProducto
    @IdProducto int,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM DETALLE_VENTA WHERE IdProducto = @IdProducto)
    BEGIN
        DELETE FROM PRODUCTO WHERE IdProducto = @IdProducto
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'El producto tiene ventas asociadas'
    END
END
GO
PRINT 'SP_EliminarProducto creado';

-- ================================================================
-- PARTE 7: STORED PROCEDURES - CLIENTES
-- ================================================================

-- SP Registrar Cliente
IF OBJECT_ID('SP_RegistrarCliente', 'P') IS NOT NULL DROP PROCEDURE SP_RegistrarCliente;
GO
CREATE PROCEDURE SP_RegistrarCliente
    @Nombres varchar(100), @Apellidos varchar(100), @Correo varchar(100),
    @Clave varchar(150), @Provincia varchar(100),
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM CLIENTE WHERE Correo = @Correo)
    BEGIN
        INSERT INTO CLIENTE(Nombres, Apellidos, Correo, Clave, Reestablecer, Provincia)
        VALUES (@Nombres, @Apellidos, @Correo, @Clave, 1, @Provincia)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE BEGIN
        SET @Mensaje = 'El correo del cliente ya existe'
    END
END
GO
PRINT 'SP_RegistrarCliente creado';

-- SP Login Cliente
IF OBJECT_ID('SP_LoginCliente', 'P') IS NOT NULL DROP PROCEDURE SP_LoginCliente;
GO
CREATE PROCEDURE SP_LoginCliente
    @Correo varchar(100), @Clave varchar(150),
    @Resultado int OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    IF EXISTS (SELECT IdCliente FROM CLIENTE WHERE Correo = @Correo AND Clave = @Clave)
    BEGIN
        SELECT @Resultado = IdCliente FROM CLIENTE WHERE Correo = @Correo AND Clave = @Clave
    END ELSE BEGIN
        SET @Mensaje = 'El correo o la clave no coinciden'
    END
END
GO
PRINT 'SP_LoginCliente creado';

-- ================================================================
-- PARTE 8: STORED PROCEDURES - CARRITO
-- ================================================================

-- SP Agregar al Carrito
IF OBJECT_ID('SP_AgregarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_AgregarCarrito;
GO
CREATE PROCEDURE SP_AgregarCarrito
    @IdCliente int, @IdProducto int, @Cantidad int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    DECLARE @StockActual int
    SELECT @StockActual = Stock FROM PRODUCTO WHERE IdProducto = @IdProducto
    IF @StockActual >= @Cantidad
    BEGIN
        IF EXISTS (SELECT * FROM CARRITO WHERE IdCliente = @IdCliente AND IdProducto = @IdProducto)
        BEGIN
            UPDATE CARRITO SET Cantidad = Cantidad + @Cantidad WHERE IdCliente = @IdCliente AND IdProducto = @IdProducto
        END ELSE BEGIN
            INSERT INTO CARRITO(IdCliente, IdProducto, Cantidad) VALUES (@IdCliente, @IdProducto, @Cantidad)
        END
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'No hay suficiente stock disponible'
    END
END
GO
PRINT 'SP_AgregarCarrito creado';

-- SP Listar Carrito
IF OBJECT_ID('SP_ListarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_ListarCarrito;
GO
CREATE PROCEDURE SP_ListarCarrito
    @IdCliente int
AS BEGIN
    SELECT c.IdCarrito, c.IdCliente, c.IdProducto, c.Cantidad,
        p.Nombre, p.Precio, p.RutaImagen, p.NombreImagen, p.Stock
    FROM CARRITO c
    INNER JOIN PRODUCTO p ON p.IdProducto = c.IdProducto
    WHERE c.IdCliente = @IdCliente
END
GO
PRINT 'SP_ListarCarrito creado';

-- SP Modificar Carrito
IF OBJECT_ID('SP_ModificarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_ModificarCarrito;
GO
CREATE PROCEDURE SP_ModificarCarrito
    @IdCarrito int, @Cantidad int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    DECLARE @StockActual int
    DECLARE @IdProducto int
    SELECT @IdProducto = IdProducto FROM CARRITO WHERE IdCarrito = @IdCarrito
    SELECT @StockActual = Stock FROM PRODUCTO WHERE IdProducto = @IdProducto
    IF @StockActual >= @Cantidad
    BEGIN
        UPDATE CARRITO SET Cantidad = @Cantidad WHERE IdCarrito = @IdCarrito
        SET @Resultado = 1
    END ELSE BEGIN
        SET @Mensaje = 'No hay suficiente stock disponible'
    END
END
GO
PRINT 'SP_ModificarCarrito creado';

-- SP Eliminar del Carrito
IF OBJECT_ID('SP_EliminarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_EliminarCarrito;
GO
CREATE PROCEDURE SP_EliminarCarrito
    @IdCarrito int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    DELETE FROM CARRITO WHERE IdCarrito = @IdCarrito
    SET @Resultado = 1
END
GO
PRINT 'SP_EliminarCarrito creado';

-- SP Contar Carrito
IF OBJECT_ID('SP_ContarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_ContarCarrito;
GO
CREATE PROCEDURE SP_ContarCarrito
    @IdCliente int, @Resultado int OUTPUT
AS BEGIN
    SELECT @Resultado = ISNULL(SUM(Cantidad), 0) FROM CARRITO WHERE IdCliente = @IdCliente
END
GO
PRINT 'SP_ContarCarrito creado';

-- ================================================================
-- PARTE 9: STORED PROCEDURES - UBICACION
-- ================================================================

-- SP Obtener Departamentos
IF OBJECT_ID('SP_ObtenerDepartamentos', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerDepartamentos;
GO
CREATE PROCEDURE SP_ObtenerDepartamentos
AS BEGIN
    SELECT IdDepartamento, Descripcion FROM DEPARTAMENTO ORDER BY Descripcion
END
GO
PRINT 'SP_ObtenerDepartamentos creado';

-- SP Obtener Provincias
IF OBJECT_ID('SP_ObtenerProvincias', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerProvincias;
GO
CREATE PROCEDURE SP_ObtenerProvincias
    @IdDepartamento varchar(5)
AS BEGIN
    SELECT IdProvincia, Descripcion FROM PROVINCIA WHERE IdDepartamento = @IdDepartamento ORDER BY Descripcion
END
GO
PRINT 'SP_ObtenerProvincias creado';

-- SP Obtener Distritos
IF OBJECT_ID('SP_ObtenerDistritos', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerDistritos;
GO
CREATE PROCEDURE SP_ObtenerDistritos
    @IdProvincia varchar(5)
AS BEGIN
    SELECT IdDistrito, Descripcion FROM DISTRITO WHERE IdProvincia = @IdProvincia ORDER BY Descripcion
END
GO
PRINT 'SP_ObtenerDistritos creado';

-- ================================================================
-- PARTE 10: STORED PROCEDURES - VENTAS
-- ================================================================

-- SP Registrar Venta
IF OBJECT_ID('SP_RegistrarVenta', 'P') IS NOT NULL DROP PROCEDURE SP_RegistrarVenta;
GO
CREATE PROCEDURE SP_RegistrarVenta
    @IdCliente int, @TotalProducto int, @MontoTotal decimal(10,2),
    @Contacto varchar(50), @IdDistrito varchar(10), @Telefono varchar(50),
    @Direccion varchar(500), @IdTransaccion varchar(50),
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    DECLARE @IdVenta int
    BEGIN TRANSACTION
    BEGIN TRY
        INSERT INTO VENTA(IdCliente, TotalProducto, MontoTotal, Contacto, IdDistrito, Telefono, Direccion, IdTransaccion)
        VALUES (@IdCliente, @TotalProducto, @MontoTotal, @Contacto, @IdDistrito, @Telefono, @Direccion, @IdTransaccion)
        SET @IdVenta = SCOPE_IDENTITY()
        INSERT INTO DETALLE_VENTA(IdVenta, IdProducto, Cantidad, Total)
        SELECT @IdVenta, IdProducto, Cantidad, (Cantidad * (SELECT Precio FROM PRODUCTO WHERE IdProducto = CARRITO.IdProducto))
        FROM CARRITO WHERE IdCliente = @IdCliente
        UPDATE PRODUCTO SET Stock = Stock - C.Cantidad
        FROM PRODUCTO p INNER JOIN CARRITO C ON p.IdProducto = C.IdProducto
        WHERE C.IdCliente = @IdCliente
        DELETE FROM CARRITO WHERE IdCliente = @IdCliente
        SET @Resultado = 1
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @Mensaje = ERROR_MESSAGE()
        SET @Resultado = 0
    END CATCH
END
GO
PRINT 'SP_RegistrarVenta creado';

-- SP Obtener Venta
IF OBJECT_ID('SP_ObtenerVenta', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerVenta;
GO
CREATE PROCEDURE SP_ObtenerVenta
    @IdTransaccion varchar(50)
AS BEGIN
    SELECT IdVenta, IdCliente, TotalProducto, MontoTotal, Contacto, Telefono,
        Direccion, IdTransaccion, FechaVenta
    FROM VENTA WHERE IdTransaccion = @IdTransaccion
END
GO
PRINT 'SP_ObtenerVenta creado';

-- SP Detalle Venta
IF OBJECT_ID('SP_DetalleVenta', 'P') IS NOT NULL DROP PROCEDURE SP_DetalleVenta;
GO
CREATE PROCEDURE SP_DetalleVenta
    @IdTransaccion varchar(50)
AS BEGIN
    SELECT dv.IdDetalleVenta, dv.Cantidad, dv.Total,
        p.Nombre, p.Precio
    FROM DETALLE_VENTA dv
    INNER JOIN VENTA v ON v.IdVenta = dv.IdVenta
    INNER JOIN PRODUCTO p ON p.IdProducto = dv.IdProducto
    WHERE v.IdTransaccion = @IdTransaccion
END
GO
PRINT 'SP_DetalleVenta creado';

PRINT '';
PRINT '============================================';
PRINT ' TODOS LOS STORED PROCEDURES CREADOS';
PRINT '============================================';
GO

-- ================================================================
-- PARTE 11: INSERTAR DATOS INICIALES
-- ================================================================

-- Insertar Usuario Admin
DECLARE @Msg varchar(500), @Res int;
EXEC SP_RegistrarUsuario 'Admin', 'Sistema', 'admin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 1, @Msg OUTPUT, @Res OUTPUT;
PRINT 'Usuario admin insertado';

-- Insertar Marcas
SET IDENTITY_INSERT MARCA ON;
INSERT INTO MARCA (IdMarca, Descripcion, Activo) VALUES
    (1, 'Samsung', 1), (2, 'Apple', 1), (3, 'LG', 1), (4, 'Sony', 1), (5, 'Xiaomi', 1),
    (6, 'HP', 1), (7, 'Dell', 1), (8, 'Nike', 1), (9, 'Adidas', 1), (10, 'Toyota', 1),
    (11, 'Honda', 1), (12, 'Lenovo', 1), (13, 'Asus', 1), (14, 'Huawei', 1), (15, 'Motorola', 1);
SET IDENTITY_INSERT MARCA OFF;
DBCC CHECKIDENT ('MARCA', RESEED, 15);
PRINT '15 Marcas insertadas';

-- Insertar Categorias
SET IDENTITY_INSERT CATEGORIA ON;
INSERT INTO CATEGORIA (IdCategoria, Descripcion, Activo) VALUES
    (1, 'Electronica', 1), (2, 'Computadoras', 1), (3, 'Telefonia', 1), (4, 'Hogar', 1),
    (5, 'Deportes', 1), (6, 'Moda', 1), (7, 'Automoviles', 1), (8, 'Entretenimiento', 1),
    (9, 'Salud', 1), (10, 'Alimentos', 1), (11, 'Belleza', 1), (12, 'Juguetes', 1);
SET IDENTITY_INSERT CATEGORIA OFF;
DBCC CHECKIDENT ('CATEGORIA', RESEED, 12);
PRINT '12 Categorias insertadas';

-- Insertar Departamentos (Regiones de Republica Dominicana)
INSERT INTO DEPARTAMENTO VALUES
    ('01', 'Region Norte'), ('02', 'Region Sur'), ('03', 'Region Este'),
    ('04', 'Region Oeste'), ('05', 'Noroeste'), ('06', 'Sureste'),
    ('07', 'Suroeste'), ('08', 'Santo Domingo Norte'), ('09', 'Santo Domingo Sur'),
    ('10', 'Santo Domingo Este'), ('11', 'Santo Domingo Oeste'),
    ('12', 'San Cristobal'), ('13', 'El Valle'), ('14', 'Enriquillo');
PRINT '14 Departamentos insertados';

-- Insertar Provincias
INSERT INTO PROVINCIA VALUES
    ('0101', 'Santiago', '01'), ('0102', 'Puerto Plata', '01'), ('0103', 'La Vega', '01'),
    ('0104', 'Espaillat', '01'), ('0105', 'Duarte', '01'), ('0106', 'Maria Trinidad Sanchez', '01'),
    ('0107', 'Montecristi', '01'), ('0108', 'Sanchez Ramirez', '01'),
    ('0201', 'San Juan', '02'), ('0202', 'Barahona', '02'), ('0203', 'Baoruco', '02'),
    ('0204', 'Independencia', '02'), ('0205', 'Pedernales', '02'),
    ('0301', 'La Altagracia (Punta Cana)', '03'), ('0302', 'La Romana', '03'),
    ('0303', 'San Pedro de Macoris', '03'), ('0304', 'Hato Mayor', '03'), ('0305', 'El Seibo', '03'),
    ('0401', 'Azua', '04'), ('0402', 'Peravia', '04'),
    ('0501', 'Monte Cristi', '05'), ('0502', 'Valverde', '05'), ('0503', 'Dajabon', '05'),
    ('0601', 'San Pedro de Macoris', '06'),
    ('0701', 'San Juan', '07'), ('0702', 'Baoruco', '07'), ('0703', 'Elias Pina', '07'),
    ('0801', 'Santo Domingo Norte', '08'), ('0802', 'Villa Mella', '08'),
    ('0901', 'San Pedro de Macoris', '09'),
    ('1001', 'Santo Domingo Este', '10'), ('1002', 'San Luis', '10'),
    ('1101', 'Santo Domingo Oeste', '11'), ('1102', 'Los Alcarrizos', '11'),
    ('1103', 'Pedro Brand', '11'),
    ('1201', 'San Cristobal', '12'), ('1202', 'San Antonio de Guerra', '12'),
    ('1301', 'Samana', '13'), ('1302', 'Sanchez Ramirez', '13'),
    ('1401', 'Barahona', '14'), ('1402', 'Baoruco', '14'), ('1403', 'Pedernales', '14');
PRINT '43 Provincias insertadas';

-- Insertar Distritos
INSERT INTO DISTRITO VALUES
    ('010101', 'Santiago Centro', '0101', '01'), ('010102', 'La Otra Banda', '0101', '01'),
    ('010103', 'Bisono', '0101', '01'), ('010104', 'Sabana Iglesia', '0101', '01'),
    ('010201', 'Puerto Plata Centro', '0102', '01'), ('010202', 'Sosua', '0102', '01'),
    ('010203', 'Cabarete', '0102', '01'), ('010301', 'La Vega Centro', '0103', '01'),
    ('010302', 'Constanza', '0103', '01'), ('010303', 'Jarabacoa', '0103', '01'),
    ('010401', 'Moca Centro', '0104', '01'), ('010501', 'San Francisco de Macoris', '0105', '01'),
    ('010601', 'Nagua Centro', '0106', '01'),
    ('020101', 'San Juan Centro', '0201', '02'), ('020201', 'Barahona Centro', '0202', '02'),
    ('030101', 'Punta Cana', '0301', '03'), ('030102', 'Bavaro', '0301', '03'),
    ('030103', 'Higuey Centro', '0301', '03'), ('030201', 'La Romana Centro', '0302', '03'),
    ('030202', 'Casa de Campo', '0302', '03'), ('030301', 'San Pedro Centro', '0303', '03'),
    ('030302', 'Juan Dolio', '0303', '03'), ('040101', 'Azua Centro', '0401', '04'),
    ('040201', 'Bani Centro', '0402', '04'),
    ('080101', 'Villa Duarte', '0801', '08'), ('080102', 'Los Minas', '0801', '08'),
    ('080103', 'Gualey', '0801', '08'), ('080201', 'Villa Mella Centro', '0802', '08'),
    ('100101', 'San Isidro', '1001', '10'), ('100102', 'Los Frailes', '1001', '10'),
    ('100201', 'San Luis Centro', '1002', '10'),
    ('110101', 'Buenos Aires', '1101', '11'), ('110102', 'Manoguayabo', '1101', '11'),
    ('110201', 'Los Alcarrizos', '1102', '11'), ('110202', 'Pantoja', '1102', '11'),
    ('120101', 'San Cristobal Centro', '1201', '12'), ('120102', 'Cambia El Fuete', '1201', '12'),
    ('130101', 'Samana Centro', '1301', '13'), ('130102', 'Las Terrenas', '1301', '13');
PRINT '41 Distritos insertados';

-- Insertar Productos de ejemplo
SET IDENTITY_INSERT PRODUCTO ON;
INSERT INTO PRODUCTO (IdProducto, Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, Activo) VALUES
    (1, 'Smart TV 55 Pulgadas 4K Ultra HD', 'Television inteligente con resolucion 4K Ultra HD y HDR. Control remoto por voz.', 1, 1, 599.99, 25, 1),
    (2, 'iPhone 15 Pro Max 256GB', 'Telefono de ultima generacion con camara de 48MP y chip A17 Pro.', 2, 3, 1199.99, 15, 1),
    (3, 'Laptop Samsung Galaxy Book 3', 'Laptop con procesador Intel Core i7, 16GB RAM y SSD 512GB.', 1, 2, 999.99, 20, 1),
    (4, 'Audifonos Sony WH-1000XM5', 'Audifonos inalambricos con cancelacion activa de ruido premium.', 4, 1, 349.99, 50, 1),
    (5, 'Refrigeradora LG Smart Inverter 22 pies', 'Refrigeradora de 22 pies cubicos con tecnologia inverter y dispensador de agua.', 3, 4, 799.99, 12, 1),
    (6, 'MacBook Air M3 13 Pulgadas', 'Laptop ultradelgada con chip M3, 8GB RAM y 256GB SSD.', 2, 2, 1099.99, 18, 1),
    (7, 'Xiaomi 13 Pro 5G', 'Smartphone con camara Leica de 50MP y carga rapida 120W.', 5, 3, 699.99, 30, 1),
    (8, 'PlayStation 5 Digital Edition', 'Consola de videojuegos de ultima generacion con control DualSense.', 4, 8, 499.99, 10, 1),
    (9, 'Zapatillas Nike Air Max 270', 'Zapatos deportivos con tecnologia Air Max y suela amortiguada.', 8, 5, 129.99, 45, 1),
    (10, 'Toyota Corolla 2024 SE', 'Vehiculo sedan compacto, eficiente en combustible y con seguridad avanzada.', 10, 7, 25999.99, 5, 1),
    (11, 'Bicicleta MTB Montain Pro 27.5', 'Bicicleta de montana con cuadro de aluminio y suspension delantera.', 9, 5, 399.99, 15, 1),
    (12, 'Lavadora LG carga frontal 18kg', 'Lavadora de carga frontal con 18 programas y turbotub.', 3, 4, 549.99, 20, 1),
    (13, 'AirPods Pro 2da Generacion', 'Audifonos True Wireless con cancelacion activa y modo transparencia.', 2, 1, 249.99, 40, 1),
    (14, 'Samsung Galaxy Tab S9 Ultra', 'Tablet premium 12.4 pulgadas con stylus S Pen incluido.', 1, 1, 799.99, 22, 1),
    (15, 'Cocina de Gas Sony 6 Hornillas', 'Cocina a gas de acero inoxidable con 6 hornillas y horno.', 4, 4, 349.99, 18, 1),
    (16, 'Adidas Ultraboost 23', 'Zapatillas para correr con tecnologia Boost y upper de punto elastico.', 9, 5, 159.99, 35, 1),
    (17, 'TV LG OLED 65 Pulgadas C4', 'Television OLED con negros perfectos, 120Hz y Dolby Vision.', 3, 1, 1499.99, 8, 1),
    (18, 'Honda Civic Sport 2024', 'Sedan deportivo con motor 1.5L turbo y transmision CVT.', 11, 7, 28999.99, 3, 1),
    (19, 'Monitor Dell 27 Pulgadas QHD', 'Monitor profesional con resolucion 2560x1440 y panel IPS.', 7, 2, 349.99, 25, 1),
    (20, 'Impresora HP LaserJet Pro MFP', 'Impresora laser monocromatica multifuncion de alta velocidad.', 6, 2, 199.99, 30, 1),
    (21, 'Samsung Galaxy S24 Ultra', 'Flagship con camara de 200MP, S Pen integrado y Galaxy AI.', 1, 3, 1099.99, 20, 1),
    (22, 'Lenovo ThinkPad X1 Carbon Gen 11', 'Laptop empresarial ultraligera de 14 pulgadas con Core i7.', 12, 2, 1499.99, 12, 1),
    (23, 'Asus ROG Phone 8 Pro', 'Celular gamer con Snapdragon 8 Gen 3 y pantalla 165Hz.', 13, 3, 799.99, 18, 1),
    (24, 'Motorola Razr 40 Ultra', 'Celular plegable con pantalla externa de 3.6 pulgadas.', 15, 3, 999.99, 10, 1),
    (25, 'Smartwatch Apple Watch Ultra 2', 'Reloj inteligente resistente con GPS de precision y titanio.', 2, 9, 799.99, 15, 1);
SET IDENTITY_INSERT PRODUCTO OFF;
DBCC CHECKIDENT ('PRODUCTO', RESEED, 25);
PRINT '25 Productos insertados';

PRINT '';
PRINT '============================================';
PRINT ' DATOS INICIALES INSERTADOS';
PRINT '============================================';
GO

-- ================================================================
-- MENSAJE FINAL
-- ================================================================
PRINT '';
PRINT '============================================';
PRINT ' INSTALACION COMPLETADA EXITOSAMENTE';
PRINT '============================================';
PRINT '';
PRINT 'DATOS DE ACCESO AL PANEL DE ADMIN:';
PRINT '============================================';
PRINT 'Usuario: admin';
PRINT 'Contrasena: admin';
PRINT '';
PRINT 'NOTA: La primera vez que accedas deberas';
PRINT 'cambiar la contrasena.';
PRINT '';
PRINT '============================================';
PRINT 'INFORMACION DE LA BASE DE DATOS:';
PRINT '============================================';
PRINT 'Base de datos: DBCARRITOTEST';
PRINT 'Tablas: 11';
PRINT 'Stored Procedures: 26';
PRINT 'Marcas: 15';
PRINT 'Categorias: 12';
PRINT 'Provincias RD: 43';
PRINT 'Distritos RD: 41';
PRINT 'Productos de ejemplo: 25';
PRINT '';
PRINT '============================================';
PRINT 'CONEXION EN WEB.CONFIG:';
PRINT '============================================';
PRINT 'Data Source: (localdb)\\MSSQLLocalDB';
PRINT 'Initial Catalog: DBCARRITOTEST';
PRINT 'Integrated Security: True';
PRINT '';
GO
