-- ================================================================
-- SCRIPT DE INSTALACIÓN COMPLETA - CARRITO DE COMPRAS
-- Compatible con: SQL Server 2012 en adelante
-- ================================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DBCARRITOTEST')
BEGIN
    ALTER DATABASE DBCARRITOTEST SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBCARRITOTEST;
END
CREATE DATABASE DBCARRITOTEST;
GO

USE DBCARRITOTEST;
GO

-- ================================================================
-- TABLAS
-- ================================================================

CREATE TABLE MARCA(
    IdMarca int identity(1,1) primary key, 
    Descripcion varchar(100), 
    Activo bit default 1
);
GO

CREATE TABLE CATEGORIA(
    IdCategoria int identity(1,1) primary key, 
    Descripcion varchar(100), 
    Activo bit default 1
);
GO

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
GO

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
GO

CREATE TABLE DEPARTAMENTO(
    IdDepartamento varchar(5) primary key, 
    Descripcion varchar(100)
);
GO

CREATE TABLE PROVINCIA(
    IdProvincia varchar(5) primary key, 
    Descripcion varchar(100), 
    IdDepartamento varchar(5) references DEPARTAMENTO(IdDepartamento)
);
GO

CREATE TABLE DISTRITO(
    IdDistrito varchar(10) primary key, 
    Descripcion varchar(100), 
    IdProvincia varchar(5) references PROVINCIA(IdProvincia), 
    IdDepartamento varchar(5) references DEPARTAMENTO(IdDepartamento)
);
GO

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
GO

CREATE TABLE CARRITO(
    IdCarrito int identity(1,1) primary key, 
    IdCliente int references CLIENTE(IdCliente), 
    IdProducto int references PRODUCTO(IdProducto), 
    Cantidad int
);
GO

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
GO

CREATE TABLE DETALLE_VENTA(
    IdDetalleVenta int identity(1,1) primary key, 
    IdVenta int references VENTA(IdVenta), 
    IdProducto int references PRODUCTO(IdProducto), 
    Cantidad int, 
    Total decimal(10,2)
);
GO

PRINT '11 TABLAS CREADAS';
GO

-- ================================================================
-- STORED PROCEDURES - USUARIOS
-- ================================================================

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
    END
END
GO

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
    END
END
GO

IF OBJECT_ID('SP_ReestablecerClave', 'P') IS NOT NULL DROP PROCEDURE SP_ReestablecerClave;
GO
CREATE PROCEDURE SP_ReestablecerClave
    @Correo varchar(100),
    @Resultado int OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    DECLARE @NuevaClave varchar(150) = LEFT(CONVERT(varchar(36), NEWID()), 8)
    DECLARE @IdUsuario int
    SELECT @IdUsuario = IdUsuario FROM USUARIO WHERE Correo = @Correo AND Activo = 1
    IF @IdUsuario > 0
    BEGIN
        UPDATE USUARIO SET Clave = @NuevaClave, Reestablecer = 1 WHERE IdUsuario = @IdUsuario
        SET @Resultado = @IdUsuario
        SET @Mensaje = @NuevaClave
    END
END
GO

-- ================================================================
-- STORED PROCEDURES - MARCAS
-- ================================================================

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
    END
END
GO

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
    END
END
GO

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
    END
END
GO

-- ================================================================
-- STORED PROCEDURES - CATEGORIAS
-- ================================================================

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
    END
END
GO

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
    END
END
GO

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
    END
END
GO

-- ================================================================
-- STORED PROCEDURES - PRODUCTOS
-- ================================================================

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

IF OBJECT_ID('SP_EditarProducto', 'P') IS NOT NULL DROP PROCEDURE SP_EditarProducto;
GO
CREATE PROCEDURE SP_EditarProducto
    @IdProducto int, @Nombre varchar(500), @Descripcion varchar(500),
    @IdMarca int, @IdCategoria int, @Precio decimal(10,2), @Stock int, @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
AS BEGIN
    SET @Resultado = 1
    UPDATE PRODUCTO SET Nombre = @Nombre, Descripcion = @Descripcion, IdMarca = @IdMarca,
        IdCategoria = @IdCategoria, Precio = @Precio, Stock = @Stock, Activo = @Activo
    WHERE IdProducto = @IdProducto
END
GO

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
    END
END
GO

IF OBJECT_ID('SP_ListarProducto', 'P') IS NOT NULL DROP PROCEDURE SP_ListarProducto;
GO
CREATE PROCEDURE SP_ListarProducto
AS BEGIN
    SELECT p.IdProducto, p.Nombre, p.Descripcion,
        m.IdMarca, m.Descripcion AS DesMarca,
        c.IdCategoria, c.Descripcion AS DesCategoria,
        p.Precio, p.Stock, p.RutaImagen, p.NombreImagen, p.Activo
    FROM PRODUCTO p
    LEFT JOIN MARCA m ON m.IdMarca = p.IdMarca
    LEFT JOIN CATEGORIA c ON c.IdCategoria = p.IdCategoria
    ORDER BY p.IdProducto DESC
END
GO

IF OBJECT_ID('SP_ListarProductoTienda', 'P') IS NOT NULL DROP PROCEDURE SP_ListarProductoTienda;
GO
CREATE PROCEDURE SP_ListarProductoTienda
AS BEGIN
    SELECT p.IdProducto, p.Nombre, p.Descripcion,
        m.IdMarca, m.Descripcion AS DesMarca,
        c.IdCategoria, c.Descripcion AS DesCategoria,
        p.Precio, p.Stock, p.RutaImagen, p.NombreImagen, p.Activo
    FROM PRODUCTO p
    LEFT JOIN MARCA m ON m.IdMarca = p.IdMarca
    LEFT JOIN CATEGORIA c ON c.IdCategoria = p.IdCategoria
    WHERE p.Activo = 1 AND p.Stock > 0
    ORDER BY p.FechaRegistro DESC
END
GO

-- ================================================================
-- STORED PROCEDURES - CLIENTES
-- ================================================================

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
    END
END
GO

IF OBJECT_ID('SP_LoginCliente', 'P') IS NOT NULL DROP PROCEDURE SP_LoginCliente;
GO
CREATE PROCEDURE SP_LoginCliente
    @Correo varchar(100), @Clave varchar(150),
    @Resultado int OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF EXISTS (SELECT IdCliente FROM CLIENTE WHERE Correo = @Correo AND Clave = @Clave)
    BEGIN
        SELECT @Resultado = IdCliente FROM CLIENTE WHERE Correo = @Correo AND Clave = @Clave
    END
END
GO

-- ================================================================
-- STORED PROCEDURES - CARRITO
-- ================================================================

IF OBJECT_ID('SP_AgregarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_AgregarCarrito;
GO
CREATE PROCEDURE SP_AgregarCarrito
    @IdCliente int, @IdProducto int, @Cantidad int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
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
    END
END
GO

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

IF OBJECT_ID('SP_ModificarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_ModificarCarrito;
GO
CREATE PROCEDURE SP_ModificarCarrito
    @IdCarrito int, @Cantidad int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    DECLARE @StockActual int
    DECLARE @IdProducto int
    SELECT @IdProducto = IdProducto FROM CARRITO WHERE IdCarrito = @IdCarrito
    SELECT @StockActual = Stock FROM PRODUCTO WHERE IdProducto = @IdProducto
    IF @StockActual >= @Cantidad
    BEGIN
        UPDATE CARRITO SET Cantidad = @Cantidad WHERE IdCarrito = @IdCarrito
        SET @Resultado = 1
    END
END
GO

IF OBJECT_ID('SP_EliminarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_EliminarCarrito;
GO
CREATE PROCEDURE SP_EliminarCarrito
    @IdCarrito int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 1
    DELETE FROM CARRITO WHERE IdCarrito = @IdCarrito
END
GO

IF OBJECT_ID('SP_ContarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_ContarCarrito;
GO
CREATE PROCEDURE SP_ContarCarrito
    @IdCliente int, @Resultado int OUTPUT
AS BEGIN
    SELECT @Resultado = ISNULL(SUM(Cantidad), 0) FROM CARRITO WHERE IdCliente = @IdCliente
END
GO

IF OBJECT_ID('SP_LimpiarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_LimpiarCarrito;
GO
CREATE PROCEDURE SP_LimpiarCarrito
    @IdCliente int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 1
    DELETE FROM CARRITO WHERE IdCliente = @IdCliente
END
GO

-- ================================================================
-- STORED PROCEDURES - UBICACION
-- ================================================================

IF OBJECT_ID('SP_ObtenerDepartamentos', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerDepartamentos;
GO
CREATE PROCEDURE SP_ObtenerDepartamentos
AS BEGIN
    SELECT IdDepartamento, Descripcion FROM DEPARTAMENTO ORDER BY Descripcion
END
GO

IF OBJECT_ID('SP_ObtenerProvincias', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerProvincias;
GO
CREATE PROCEDURE SP_ObtenerProvincias
    @IdDepartamento varchar(5)
AS BEGIN
    SELECT IdProvincia, Descripcion FROM PROVINCIA WHERE IdDepartamento = @IdDepartamento ORDER BY Descripcion
END
GO

IF OBJECT_ID('SP_ObtenerDistritos', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerDistritos;
GO
CREATE PROCEDURE SP_ObtenerDistritos
    @IdProvincia varchar(5)
AS BEGIN
    SELECT IdDistrito, Descripcion FROM DISTRITO WHERE IdProvincia = @IdProvincia ORDER BY Descripcion
END
GO

-- ================================================================
-- STORED PROCEDURES - VENTAS
-- ================================================================

IF OBJECT_ID('SP_RegistrarVenta', 'P') IS NOT NULL DROP PROCEDURE SP_RegistrarVenta;
GO
CREATE PROCEDURE SP_RegistrarVenta
    @IdCliente int, @TotalProducto int, @MontoTotal decimal(10,2),
    @Contacto varchar(50), @IdDistrito varchar(10), @Telefono varchar(50),
    @Direccion varchar(500), @IdTransaccion varchar(50),
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
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
    END CATCH
END
GO

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

-- ================================================================
-- STORED PROCEDURES - REPORTES
-- ================================================================

IF OBJECT_ID('SP_ReporteVentas', 'P') IS NOT NULL DROP PROCEDURE SP_ReporteVentas;
GO
CREATE PROCEDURE SP_ReporteVentas
    @fechainicio varchar(50), @fechafin varchar(50), @idtransaccion varchar(50)
AS BEGIN
    DECLARE @FechaInicio datetime
    DECLARE @FechaFinMasUno datetime
    
    SET @FechaInicio = CONVERT(datetime, @fechainicio, 103)
    SET @FechaFinMasUno = DATEADD(day, 1, CONVERT(datetime, @fechafin, 103))
    
    SELECT v.FechaVenta,
        c.Nombres + ' ' + c.Apellidos AS Cliente,
        dv.Cantidad, dv.Total,
        p.Nombre AS Producto,
        p.Precio,
        v.IdTransaccion
    FROM VENTA v
    INNER JOIN CLIENTE c ON c.IdCliente = v.IdCliente
    INNER JOIN DETALLE_VENTA dv ON dv.IdVenta = v.IdVenta
    INNER JOIN PRODUCTO p ON p.IdProducto = dv.IdProducto
    WHERE v.FechaVenta >= @FechaInicio AND v.FechaVenta < @FechaFinMasUno
        AND (@idtransaccion = '' OR v.IdTransaccion LIKE '%' + @idtransaccion + '%')
END
GO

IF OBJECT_ID('SP_ReporteDashboard', 'P') IS NOT NULL DROP PROCEDURE SP_ReporteDashboard;
GO
CREATE PROCEDURE SP_ReporteDashboard
AS BEGIN
    SELECT 
        (SELECT COUNT(*) FROM CLIENTE) AS TotalCliente,
        (SELECT COUNT(*) FROM VENTA) AS TotalVenta,
        (SELECT COUNT(*) FROM PRODUCTO) AS TotalProducto
END
GO

PRINT '';
PRINT '29 STORED PROCEDURES CREADOS';
GO

-- ================================================================
-- DATOS INICIALES
-- ================================================================

INSERT INTO USUARIO (Nombre, Apellido, Correo, Clave, Reestablecer, Activo) 
VALUES ('Admin', 'Sistema', 'admin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 0, 1);
GO

SET IDENTITY_INSERT MARCA ON;
INSERT INTO MARCA (IdMarca, Descripcion, Activo) VALUES 
    (1, 'Samsung', 1), (2, 'Apple', 1), (3, 'LG', 1), (4, 'Sony', 1), (5, 'Xiaomi', 1),
    (6, 'HP', 1), (7, 'Dell', 1), (8, 'Nike', 1), (9, 'Adidas', 1), (10, 'Toyota', 1),
    (11, 'Honda', 1), (12, 'Lenovo', 1), (13, 'Asus', 1), (14, 'Huawei', 1), (15, 'Motorola', 1);
SET IDENTITY_INSERT MARCA OFF;
GO

SET IDENTITY_INSERT CATEGORIA ON;
INSERT INTO CATEGORIA (IdCategoria, Descripcion, Activo) VALUES 
    (1, 'Electronica', 1), (2, 'Computadoras', 1), (3, 'Telefonia', 1), (4, 'Hogar', 1),
    (5, 'Deportes', 1), (6, 'Moda', 1), (7, 'Automoviles', 1), (8, 'Entretenimiento', 1),
    (9, 'Salud', 1), (10, 'Alimentos', 1), (11, 'Belleza', 1), (12, 'Juguetes', 1);
SET IDENTITY_INSERT CATEGORIA OFF;
GO

INSERT INTO DEPARTAMENTO VALUES 
    ('01', 'Region Norte'), ('02', 'Region Sur'), ('03', 'Region Este'), ('04', 'Region Oeste'),
    ('08', 'Santo Domingo Norte'), ('10', 'Santo Domingo Este'), ('11', 'Santo Domingo Oeste');
GO

INSERT INTO PROVINCIA VALUES 
    ('0101', 'Santiago', '01'), ('0102', 'Puerto Plata', '01'), ('0103', 'La Vega', '01'),
    ('0301', 'La Altagracia (Punta Cana)', '03'), ('0302', 'La Romana', '03'),
    ('0801', 'Santo Domingo Norte', '08'), ('0802', 'Villa Mella', '08'),
    ('1001', 'Santo Domingo Este', '10'), ('1002', 'San Luis', '10'),
    ('1101', 'Santo Domingo Oeste', '11'), ('1102', 'Los Alcarrizos', '11');
GO

INSERT INTO DISTRITO VALUES 
    ('010101', 'Santiago Centro', '0101', '01'), ('010201', 'Puerto Plata Centro', '0102', '01'),
    ('010301', 'La Vega Centro', '0103', '01'), ('030101', 'Punta Cana', '0301', '03'),
    ('030201', 'La Romana Centro', '0302', '03'), ('080101', 'Villa Duarte', '0801', '08'),
    ('080102', 'Los Minas', '0801', '08'), ('100101', 'San Isidro', '1001', '10'),
    ('110101', 'Buenos Aires', '1101', '11'), ('110201', 'Los Alcarrizos', '1102', '11');
GO

SET IDENTITY_INSERT PRODUCTO ON;
INSERT INTO PRODUCTO (IdProducto, Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, Activo) VALUES
    (1, 'Smart TV 55 Pulgadas 4K', 'Television 4K Ultra HD HDR', 1, 1, 599.99, 25, 1),
    (2, 'iPhone 15 Pro Max', 'Telefono 48MP chip A17 Pro', 2, 3, 1199.99, 15, 1),
    (3, 'Laptop Galaxy Book 3', 'Intel Core i7 16GB RAM', 1, 2, 999.99, 20, 1),
    (4, 'Audifonos Sony WH-1000XM5', 'Cancelacion de ruido premium', 4, 1, 349.99, 50, 1),
    (5, 'Refrigeradora LG 22 pies', 'Tecnologia inverter', 3, 4, 799.99, 12, 1),
    (6, 'MacBook Air M3', 'Chip M3 8GB RAM', 2, 2, 1099.99, 18, 1),
    (7, 'Xiaomi 13 Pro 5G', 'Camara Leica 50MP', 5, 3, 699.99, 30, 1),
    (8, 'PlayStation 5', 'Consola ultima generacion', 4, 8, 499.99, 10, 1),
    (9, 'Nike Air Max 270', 'Zapatos deportivos', 8, 5, 129.99, 45, 1),
    (10, 'Toyota Corolla 2024', 'Sedan compacto', 10, 7, 25999.99, 5, 1),
    (11, 'Bicicleta MTB 27.5', 'Cuadro aluminio', 9, 5, 399.99, 15, 1),
    (12, 'Lavadora LG 18kg', 'Carga frontal', 3, 4, 549.99, 20, 1),
    (13, 'AirPods Pro 2', 'True Wireless ANC', 2, 1, 249.99, 40, 1),
    (14, 'Samsung Galaxy Tab S9', 'Tablet 12.4 pulgadas', 1, 1, 799.99, 22, 1),
    (15, 'Adidas Ultraboost 23', 'Para correr', 9, 5, 159.99, 35, 1),
    (16, 'LG OLED 65 Pulgadas', 'TV OLED negros perfectos', 3, 1, 1499.99, 8, 1),
    (17, 'Honda Civic 2024', 'Sedan deportivo', 11, 7, 28999.99, 3, 1),
    (18, 'Monitor Dell 27 QHD', '2560x1440 IPS', 7, 2, 349.99, 25, 1),
    (19, 'HP LaserJet Pro', 'Impresora laser', 6, 2, 199.99, 30, 1),
    (20, 'Samsung Galaxy S24 Ultra', '200MP S Pen', 1, 3, 1099.99, 20, 1);
SET IDENTITY_INSERT PRODUCTO OFF;
GO

PRINT '';
PRINT '============================================';
PRINT ' INSTALACION COMPLETADA EXITOSAMENTE';
PRINT '============================================';
PRINT '';
PRINT 'Admin: admin / admin';
PRINT '11 tablas, 29 procedimientos';
PRINT '20 productos, 15 marcas, 12 categorias';
PRINT '';
GO
