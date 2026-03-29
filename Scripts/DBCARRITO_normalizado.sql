-- =============================================================
-- Script completo DBCARRITO normalizado
-- Incluye: Tablas + FKs + Defaults + SPs + Datos seed
-- Corrige: CLIENTE campos, VENTA typo, UNIQUE constraints
-- =============================================================

USE [master]
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DBCARRITO')
BEGIN
    CREATE DATABASE [DBCARRITO];
END
GO

USE [DBCARRITO]
GO

-- =========================
-- TABLAS - Modulo Ubicacion
-- =========================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DEPARTAMENTO')
CREATE TABLE [dbo].[DEPARTAMENTO](
    [IdDepartamento] [varchar](2) NOT NULL,
    [Descripcion] [varchar](45) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdDepartamento] ASC)
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PROVINCIA')
CREATE TABLE [dbo].[PROVINCIA](
    [IdProvincia] [varchar](4) NOT NULL,
    [Descripcion] [varchar](45) NOT NULL,
    [IdDepartamento] [varchar](2) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdProvincia] ASC),
    FOREIGN KEY ([IdDepartamento]) REFERENCES [DEPARTAMENTO]([IdDepartamento])
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DISTRITO')
CREATE TABLE [dbo].[DISTRITO](
    [IdDistrito] [varchar](6) NOT NULL,
    [Descripcion] [varchar](45) NOT NULL,
    [IdProvincia] [varchar](4) NOT NULL,
    [IdDepartamento] [varchar](2) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdDistrito] ASC),
    FOREIGN KEY ([IdProvincia]) REFERENCES [PROVINCIA]([IdProvincia])
);
GO

-- =========================
-- TABLAS - Modulo Productos
-- =========================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CATEGORIA')
CREATE TABLE [dbo].[CATEGORIA](
    [IdCategoria] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Descripcion] [varchar](100) NULL,
    [Activo] [bit] DEFAULT 1,
    [FechaRegistro] [datetime] DEFAULT GETDATE()
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MARCA')
CREATE TABLE [dbo].[MARCA](
    [IdMarca] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Descripcion] [varchar](100) NULL,
    [Activo] [bit] DEFAULT 1,
    [FechaRegistro] [datetime] DEFAULT GETDATE()
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRODUCTO')
CREATE TABLE [dbo].[PRODUCTO](
    [IdProducto] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Nombre] [varchar](500) NULL,
    [Descripcion] [varchar](500) NULL,
    [IdMarca] [int] NULL,
    [IdCategoria] [int] NULL,
    [Precio] [decimal](10,2) DEFAULT 0,
    [Stock] [int] NULL,
    [RutaImagen] [varchar](100) NULL,
    [NombreImagen] [varchar](100) NULL,
    [Activo] [bit] DEFAULT 1,
    [FechaRegistro] [datetime] DEFAULT GETDATE(),
    FOREIGN KEY ([IdMarca]) REFERENCES [MARCA]([IdMarca]),
    FOREIGN KEY ([IdCategoria]) REFERENCES [CATEGORIA]([IdCategoria])
);
GO

-- =========================
-- TABLAS - Modulo Usuarios
-- =========================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'USUARIO')
CREATE TABLE [dbo].[USUARIO](
    [IdUsuario] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Nombre] [varchar](100) NULL,
    [Apellido] [varchar](100) NULL,
    [Correo] [varchar](100) NULL UNIQUE,
    [Clave] [varchar](150) NULL,
    [Reestablecer] [bit] DEFAULT 1,
    [Activo] [bit] DEFAULT 1,
    [FechaRegistro] [datetime] DEFAULT GETDATE()
);
GO

-- CLIENTE (CORREGIDO: Nombres/Apellidos, UNIQUE en Correo)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CLIENTE')
CREATE TABLE [dbo].[CLIENTE](
    [IdCliente] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Nombres] [varchar](100) NULL,
    [Apellidos] [varchar](100) NULL,
    [Correo] [varchar](100) NULL UNIQUE,
    [Clave] [varchar](150) NULL,
    [Reestablecer] [bit] DEFAULT 0,
    [FechaRegistro] [datetime] DEFAULT GETDATE()
);
GO

-- =========================
-- TABLAS - Modulo Ventas
-- =========================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CARRITO')
CREATE TABLE [dbo].[CARRITO](
    [IdCarrito] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [IdCliente] [int] NOT NULL,
    [IdProducto] [int] NOT NULL,
    [Cantidad] [int] NOT NULL,
    FOREIGN KEY ([IdCliente]) REFERENCES [CLIENTE]([IdCliente]),
    FOREIGN KEY ([IdProducto]) REFERENCES [PRODUCTO]([IdProducto])
);
GO

-- VENTA (CORREGIDO: Direccion sin triple c)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VENTA')
CREATE TABLE [dbo].[VENTA](
    [IdVenta] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [IdCliente] [int] NULL,
    [TotalProducto] [int] NULL,
    [MontoTotal] [decimal](10,2) NULL,
    [Contacto] [varchar](50) NULL,
    [IdDistrito] [varchar](10) NULL,
    [Telefono] [varchar](50) NULL,
    [Direccion] [varchar](500) NULL,
    [IdTransaccion] [varchar](50) NULL,
    [FechaVenta] [datetime] DEFAULT GETDATE(),
    FOREIGN KEY ([IdCliente]) REFERENCES [CLIENTE]([IdCliente])
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DETALLE_VENTA')
CREATE TABLE [dbo].[DETALLE_VENTA](
    [IdDetalleVenta] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [IdVenta] [int] NULL,
    [IdProducto] [int] NULL,
    [Cantidad] [int] NULL,
    [Total] [decimal](10,2) NULL,
    FOREIGN KEY ([IdVenta]) REFERENCES [VENTA]([IdVenta]),
    FOREIGN KEY ([IdProducto]) REFERENCES [PRODUCTO]([IdProducto])
);
GO

-- =========================
-- SPs EXISTENTES (recrear)
-- =========================

CREATE OR ALTER PROC sp_RegistrarCategoria(
    @Descripcion varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion = @Descripcion)
    BEGIN
        INSERT INTO CATEGORIA(Descripcion, Activo) VALUES (@Descripcion, @Activo)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE SET @Mensaje = 'La categoria ya existe'
END
GO

CREATE OR ALTER PROC sp_EditarCategoria(
    @IdCategoria int, @Descripcion varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion = @Descripcion AND IdCategoria != @IdCategoria)
    BEGIN
        UPDATE CATEGORIA SET Descripcion = @Descripcion, Activo = @Activo WHERE IdCategoria = @IdCategoria
        SET @Resultado = 1
    END ELSE SET @Mensaje = 'La categoria ya existe'
END
GO

CREATE OR ALTER PROC sp_EliminarCategoria(
    @IdCategoria int, @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE IdCategoria = @IdCategoria)
    BEGIN
        DELETE FROM CATEGORIA WHERE IdCategoria = @IdCategoria
        SET @Resultado = 1
    END ELSE SET @Mensaje = 'La categoria tiene productos relacionados'
END
GO

CREATE OR ALTER PROC sp_RegistrarMarca(
    @Descripcion varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM MARCA WHERE Descripcion = @Descripcion)
    BEGIN
        INSERT INTO MARCA(Descripcion, Activo) VALUES (@Descripcion, @Activo)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE SET @Mensaje = 'La Marca ya existe'
END
GO

CREATE OR ALTER PROC sp_EditarMarca(
    @IdMarca int, @Descripcion varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM MARCA WHERE Descripcion = @Descripcion AND IdMarca != @IdMarca)
    BEGIN
        UPDATE MARCA SET Descripcion = @Descripcion, Activo = @Activo WHERE IdMarca = @IdMarca
        SET @Resultado = 1
    END ELSE SET @Mensaje = 'La Marca ya existe'
END
GO

CREATE OR ALTER PROC sp_EliminarMarca(
    @IdMarca int, @Mensaje varchar(500) OUTPUT, @Resultado bit OUTPUT
) AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE IdMarca = @IdMarca)
    BEGIN
        DELETE FROM MARCA WHERE IdMarca = @IdMarca
        SET @Resultado = 1
    END ELSE SET @Mensaje = 'La Marca tiene productos relacionados'
END
GO

CREATE OR ALTER PROC sp_ListarProducto
AS BEGIN
    SELECT p.IdProducto, p.Nombre, p.Descripcion,
        ISNULL(m.IdMarca, 0) as IdMarca, ISNULL(m.Descripcion, 'Sin Marca') AS DesMarca,
        ISNULL(c.IdCategoria, 0) as IdCategoria, ISNULL(c.Descripcion, 'Sin Categoria') AS DesCategoria,
        p.Precio, p.Stock, p.RutaImagen, p.NombreImagen, p.Activo
    FROM PRODUCTO p
    LEFT JOIN MARCA m ON m.IdMarca = p.IdMarca
    LEFT JOIN CATEGORIA c ON c.IdCategoria = p.IdCategoria
END
GO

CREATE OR ALTER PROC sp_RegistrarProducto(
    @Nombre varchar(100), @Descripcion varchar(100), @IdMarca int, @IdCategoria int,
    @Precio decimal(10,2), @Stock int, @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE Nombre = @Nombre)
    BEGIN
        INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, Activo)
        VALUES (@Nombre, @Descripcion, @IdMarca, @IdCategoria, @Precio, @Stock, @Activo)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE SET @Mensaje = 'El producto ya existe'
END
GO

CREATE OR ALTER PROC sp_EditarProducto(
    @IdProducto int, @Nombre varchar(100), @Descripcion varchar(100),
    @IdMarca int, @IdCategoria int, @Precio decimal(10,2), @Stock int, @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE Nombre = @Nombre AND IdProducto != @IdProducto)
    BEGIN
        UPDATE PRODUCTO SET Nombre=@Nombre, Descripcion=@Descripcion, IdMarca=@IdMarca,
            IdCategoria=@IdCategoria, Precio=@Precio, Stock=@Stock, Activo=@Activo
        WHERE IdProducto=@IdProducto
        SET @Resultado = 1
    END ELSE SET @Mensaje = 'El producto ya existe'
END
GO

CREATE OR ALTER PROC sp_EliminarProducto(
    @IdProducto int, @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM DETALLE_VENTA WHERE IdProducto = @IdProducto)
    BEGIN
        DELETE FROM PRODUCTO WHERE IdProducto = @IdProducto
        SET @Resultado = 1
    END ELSE SET @Mensaje = 'El producto esta relacionado a una venta'
END
GO

CREATE OR ALTER PROC sp_RegistrarUsuario(
    @Nombres varchar(100), @Apellidos varchar(100), @Correo varchar(100),
    @Clave varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM USUARIO WHERE Correo = @Correo)
    BEGIN
        INSERT INTO USUARIO(Nombre, Apellido, Correo, Clave, Reestablecer, Activo)
        VALUES (@Nombres, @Apellidos, @Correo, @Clave, 1, @Activo)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE SET @Mensaje = 'El correo ya existe'
END
GO

CREATE OR ALTER PROC sp_EditarUsuario(
    @IdUsuario int, @Nombres varchar(100), @Apellidos varchar(100),
    @Correo varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM USUARIO WHERE Correo = @Correo AND IdUsuario != @IdUsuario)
    BEGIN
        UPDATE USUARIO SET Nombre=@Nombres, Apellido=@Apellidos, Correo=@Correo, Activo=@Activo
        WHERE IdUsuario=@IdUsuario
        SET @Resultado = 1
    END ELSE SET @Mensaje = 'El correo ya existe'
END
GO

CREATE OR ALTER PROC sp_ReporteDashboard
AS BEGIN
    SELECT
        (SELECT COUNT(*) FROM CLIENTE) [TotalCliente],
        (SELECT COUNT(*) FROM VENTA) [TotalVenta],
        (SELECT COUNT(*) FROM PRODUCTO) [TotalProducto]

    SELECT
        CONVERT(char(10), v.FechaVenta, 103) [FechaVenta],
        v.Contacto [Cliente],
        p.Nombre [Producto],
        p.Precio,
        dv.Cantidad,
        v.MontoTotal [Total],
        v.IdTransaccion
    FROM VENTA v
    INNER JOIN DETALLE_VENTA dv ON v.IdVenta = dv.IdVenta
    INNER JOIN PRODUCTO p ON dv.IdProducto = p.IdProducto
END
GO

CREATE OR ALTER PROC sp_ReporteVentas(
    @fechainicio varchar(10), @fechafin varchar(10), @idtransaccion varchar(50)
) AS BEGIN
    SET DATEFORMAT dmy;
    SELECT CONVERT(char(10), v.FechaVenta, 103) [FechaVenta],
        CONCAT(c.Nombres, ' ', c.Apellidos) [Cliente],
        p.Nombre [Producto], p.Precio, dv.Cantidad, dv.Total, v.IdTransaccion
    FROM VENTA v
    INNER JOIN CLIENTE c ON c.IdCliente = v.IdCliente
    LEFT JOIN DETALLE_VENTA dv ON v.IdVenta = dv.IdVenta
    LEFT JOIN PRODUCTO p ON p.IdProducto = dv.IdProducto
    WHERE CONVERT(date, v.FechaVenta) BETWEEN @fechainicio AND @fechafin
        AND v.IdTransaccion = IIF(@idtransaccion = '', v.IdTransaccion, @idtransaccion)
END
GO

-- =========================
-- SPs NUEVOS: CLIENTE
-- =========================

CREATE OR ALTER PROC sp_RegistrarCliente(
    @Nombres varchar(100), @Apellidos varchar(100),
    @Correo varchar(100), @Clave varchar(150),
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM CLIENTE WHERE Correo = @Correo)
    BEGIN
        INSERT INTO CLIENTE(Nombres, Apellidos, Correo, Clave)
        VALUES (@Nombres, @Apellidos, @Correo, @Clave)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE SET @Mensaje = 'El correo del cliente ya existe'
END
GO

CREATE OR ALTER PROC sp_LoginCliente(
    @Correo varchar(100), @Clave varchar(150),
    @Resultado int OUTPUT, @Mensaje varchar(500) OUTPUT
) AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    IF EXISTS (SELECT * FROM CLIENTE WHERE Correo = @Correo AND Clave = @Clave)
    BEGIN
        SET @Resultado = (SELECT IdCliente FROM CLIENTE WHERE Correo = @Correo AND Clave = @Clave)
    END ELSE SET @Mensaje = 'Correo o contraseña incorrectos'
END
GO

-- =========================
-- SPs NUEVOS: CARRITO
-- =========================

CREATE OR ALTER PROC sp_AgregarCarrito(
    @IdCliente int, @IdProducto int, @Cantidad int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
) AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    IF EXISTS (SELECT * FROM CARRITO WHERE IdCliente = @IdCliente AND IdProducto = @IdProducto)
    BEGIN
        UPDATE CARRITO SET Cantidad = Cantidad + @Cantidad
        WHERE IdCliente = @IdCliente AND IdProducto = @IdProducto
        SET @Resultado = 1
    END ELSE BEGIN
        INSERT INTO CARRITO(IdCliente, IdProducto, Cantidad)
        VALUES (@IdCliente, @IdProducto, @Cantidad)
        SET @Resultado = 1
    END
END
GO

CREATE OR ALTER PROC sp_ListarCarrito(
    @IdCliente int
) AS BEGIN
    SELECT c.IdCarrito, c.Cantidad,
        p.IdProducto, p.Nombre, p.Precio, p.RutaImagen, p.NombreImagen, p.Stock,
        (p.Precio * c.Cantidad) as SubTotal
    FROM CARRITO c
    INNER JOIN PRODUCTO p ON c.IdProducto = p.IdProducto
    WHERE c.IdCliente = @IdCliente
END
GO

CREATE OR ALTER PROC sp_ModificarCarrito(
    @IdCarrito int, @Cantidad int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
) AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    UPDATE CARRITO SET Cantidad = @Cantidad WHERE IdCarrito = @IdCarrito
    SET @Resultado = 1
END
GO

CREATE OR ALTER PROC sp_EliminarCarrito(
    @IdCarrito int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
) AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    DELETE FROM CARRITO WHERE IdCarrito = @IdCarrito
    SET @Resultado = 1
END
GO

CREATE OR ALTER PROC sp_LimpiarCarrito(
    @IdCliente int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
) AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    DELETE FROM CARRITO WHERE IdCliente = @IdCliente
    SET @Resultado = 1
END
GO

CREATE OR ALTER PROC sp_ContarCarrito(
    @IdCliente int,
    @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = (SELECT ISNULL(SUM(Cantidad), 0) FROM CARRITO WHERE IdCliente = @IdCliente)
END
GO

-- =========================
-- SPs NUEVOS: VENTA / CHECKOUT
-- =========================

CREATE OR ALTER PROC sp_RegistrarVenta(
    @IdCliente int, @TotalProducto int, @MontoTotal decimal(10,2),
    @Contacto varchar(50), @IdDistrito varchar(10),
    @Telefono varchar(50), @Direccion varchar(500), @IdTransaccion varchar(50),
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
) AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    BEGIN TRY
        BEGIN TRANSACTION
        INSERT INTO VENTA(IdCliente, TotalProducto, MontoTotal, Contacto, IdDistrito, Telefono, Direccion, IdTransaccion)
        VALUES (@IdCliente, @TotalProducto, @MontoTotal, @Contacto, @IdDistrito, @Telefono, @Direccion, @IdTransaccion)
        DECLARE @IdVenta int = SCOPE_IDENTITY()
        INSERT INTO DETALLE_VENTA(IdVenta, IdProducto, Cantidad, Total)
        SELECT @IdVenta, c.IdProducto, c.Cantidad, (p.Precio * c.Cantidad)
        FROM CARRITO c
        INNER JOIN PRODUCTO p ON c.IdProducto = p.IdProducto
        WHERE c.IdCliente = @IdCliente
        UPDATE p SET p.Stock = p.Stock - c.Cantidad
        FROM PRODUCTO p
        INNER JOIN CARRITO c ON p.IdProducto = c.IdProducto
        WHERE c.IdCliente = @IdCliente
        DELETE FROM CARRITO WHERE IdCliente = @IdCliente
        SET @Resultado = 1
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @Mensaje = ERROR_MESSAGE()
    END CATCH
END
GO

CREATE OR ALTER PROC sp_ObtenerVenta(
    @IdTransaccion varchar(50)
) AS BEGIN
    SELECT v.IdVenta, v.IdCliente, v.TotalProducto, v.MontoTotal, v.Contacto,
        v.Telefono, v.Direccion, v.IdTransaccion, v.FechaVenta,
        cl.Nombres, cl.Apellidos
    FROM VENTA v
    INNER JOIN CLIENTE cl ON v.IdCliente = cl.IdCliente
    WHERE v.IdTransaccion = @IdTransaccion
END
GO

CREATE OR ALTER PROC sp_DetalleVenta(
    @IdTransaccion varchar(50)
) AS BEGIN
    SELECT dv.IdDetalleVenta, dv.Cantidad, dv.Total,
        p.Nombre, p.Precio
    FROM DETALLE_VENTA dv
    INNER JOIN VENTA v ON dv.IdVenta = v.IdVenta
    INNER JOIN PRODUCTO p ON dv.IdProducto = p.IdProducto
    WHERE v.IdTransaccion = @IdTransaccion
END
GO

-- =========================
-- SPs NUEVOS: CATALOGO TIENDA
-- =========================

CREATE OR ALTER PROC sp_ListarProductoTienda
AS BEGIN
    SELECT p.IdProducto, p.Nombre, p.Descripcion,
        ISNULL(m.IdMarca, 0) as IdMarca, ISNULL(m.Descripcion, '') AS DesMarca,
        ISNULL(c.IdCategoria, 0) as IdCategoria, ISNULL(c.Descripcion, '') AS DesCategoria,
        p.Precio, p.Stock, p.RutaImagen, p.NombreImagen
    FROM PRODUCTO p
    LEFT JOIN MARCA m ON m.IdMarca = p.IdMarca
    LEFT JOIN CATEGORIA c ON c.IdCategoria = p.IdCategoria
    WHERE p.Activo = 1 AND p.Stock > 0
END
GO

-- =========================
-- SPs NUEVOS: UBICACION
-- =========================

CREATE OR ALTER PROC sp_ObtenerDepartamentos
AS BEGIN
    SELECT IdDepartamento, Descripcion FROM DEPARTAMENTO
END
GO

CREATE OR ALTER PROC sp_ObtenerProvincias(
    @IdDepartamento varchar(2)
) AS BEGIN
    SELECT IdProvincia, Descripcion FROM PROVINCIA WHERE IdDepartamento = @IdDepartamento
END
GO

CREATE OR ALTER PROC sp_ObtenerDistritos(
    @IdProvincia varchar(4)
) AS BEGIN
    SELECT IdDistrito, Descripcion FROM DISTRITO WHERE IdProvincia = @IdProvincia
END
GO

-- =========================
-- DATOS SEED
-- =========================

IF NOT EXISTS (SELECT * FROM DEPARTAMENTO)
BEGIN
    INSERT INTO DEPARTAMENTO VALUES ('01','Arequipa'), ('02','Ica'), ('03','Lima')
END
GO

IF NOT EXISTS (SELECT * FROM PROVINCIA)
BEGIN
    INSERT INTO PROVINCIA VALUES
        ('0101','Arequipa','01'), ('0102','Camana','01'),
        ('0201','Ica','02'), ('0202','Chincha','02'),
        ('0301','Lima','03'), ('0302','Barranca','03')
END
GO

IF NOT EXISTS (SELECT * FROM DISTRITO)
BEGIN
    INSERT INTO DISTRITO VALUES
        ('010101','Nieva','0101','01'), ('010102','El Cenepa','0101','01'),
        ('010201','Camana','0102','01'), ('010202','Jose Maria Quimper','0102','01'),
        ('020101','Ica','0201','02'), ('020102','La Tinguiña','0201','02'),
        ('020201','Chincha Alta','0202','02'), ('020202','Alto Laran','0202','02'),
        ('030101','Lima','0301','03'), ('030102','Ancon','0301','03'),
        ('030201','Barranca','0302','03'), ('030202','Paramonga','0302','03')
END
GO

-- Categorias seed
IF NOT EXISTS (SELECT * FROM CATEGORIA)
BEGIN
    INSERT INTO CATEGORIA(Descripcion, Activo) VALUES
        ('Tecnologia', 1), ('Muebles', 1), ('Dormitorio', 1), ('Deporte', 1),
        ('Laptops', 1), ('Memorias RAM', 1), ('Discos Duros', 1),
        ('Perifericos', 1), ('Monitores', 1), ('Tarjetas Graficas', 1)
END
GO

-- Marcas seed
IF NOT EXISTS (SELECT * FROM MARCA)
BEGIN
    INSERT INTO MARCA(Descripcion, Activo) VALUES
        ('HP', 1), ('Dell', 1), ('Asus', 1), ('Western Digital', 1), ('Logitech', 1),
        ('Sony', 1), ('LG', 1), ('Samsung', 1)
END
GO

-- Productos seed
IF NOT EXISTS (SELECT * FROM PRODUCTO)
BEGIN
    INSERT INTO PRODUCTO(Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, Activo) VALUES
        ('Laptop Gamer', 'Laptop con procesador Intel i7 y 16GB RAM', 1, 5, 1300.00, 15, 1),
        ('Desktop Profesional', 'PC de escritorio con Ryzen 9 y 32GB RAM', 2, 5, 1599.99, 10, 1),
        ('Memoria RAM 16GB', 'DDR4 3200MHz para desktops y laptops', 3, 6, 79.99, 50, 1),
        ('Disco Duro SSD 1TB', 'SSD interno NVMe para alta velocidad', 4, 7, 119.99, 40, 1),
        ('Teclado Mecanico', 'Teclado mecanico retroiluminado RGB', 5, 8, 69.99, 25, 1),
        ('Mouse Gamer', 'Mouse ergonomico con sensor de 16000 DPI', 5, 8, 49.99, 30, 1),
        ('Monitor 27 4K', 'Monitor LED 4K UHD con HDR', 2, 9, 399.99, 12, 1),
        ('Disco Duro Externo 2TB', 'HDD externo USB 3.0', 4, 7, 89.99, 20, 1),
        ('Laptop Ultrabook', 'Laptop ligera con Intel i5 y 8GB RAM', 1, 5, 899.99, 18, 1),
        ('Tarjeta Grafica GTX 1660', 'GPU para gaming y edicion de video', 3, 10, 299.99, 8, 1)
END
GO

-- Usuario admin seed
IF NOT EXISTS (SELECT * FROM USUARIO)
BEGIN
    INSERT INTO USUARIO(Nombre, Apellido, Correo, Clave, Reestablecer, Activo) VALUES
        ('Admin', 'Sistema', 'admin@carrito.com', 'ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae', 0, 1)
END
GO
