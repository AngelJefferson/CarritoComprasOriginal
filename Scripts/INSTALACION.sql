-- ====================================================================
-- SCRIPT DE INSTALACION - CARRITO DE COMPRAS
-- Ejecutar en SQL Server Management Studio
-- ====================================================================

USE master;
GO

-- Crear base de datos si no existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DBCARRITOTEST')
BEGIN
    CREATE DATABASE DBCARRITOTEST;
    PRINT 'Base de datos DBCARRITOTEST creada';
END
ELSE
BEGIN
    PRINT 'La base de datos DBCARRITOTEST ya existe';
END
GO

USE DBCARRITOTEST;
GO

-- ====================================================================
-- TABLAS
-- ====================================================================

-- MARCA
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MARCA')
BEGIN
    CREATE TABLE MARCA(
        IdMarca int identity(1,1) primary key,
        Descripcion varchar(100),
        Activo bit default 1
    );
    PRINT 'Tabla MARCA creada';
END
GO

-- CATEGORIA
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CATEGORIA')
BEGIN
    CREATE TABLE CATEGORIA(
        IdCategoria int identity(1,1) primary key,
        Descripcion varchar(100),
        Activo bit default 1
    );
    PRINT 'Tabla CATEGORIA creada';
END
GO

-- PRODUCTO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRODUCTO')
BEGIN
    CREATE TABLE PRODUCTO(
        IdProducto int identity(1,1) primary key,
        Nombre varchar(500),
        Descripcion varchar(500),
        IdMarca int references Marca(IdMarca),
        IdCategoria int references Categoria(IdCategoria),
        Precio decimal(10,2) default 0,
        Stock int,
        RutaImagen varchar(100),
        NombreImagen varchar(100),
        Activo bit default 1,
        FechaRegistro datetime default getdate()
    );
    PRINT 'Tabla PRODUCTO creada';
END
GO

-- USUARIO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'USUARIO')
BEGIN
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
END
GO

-- CLIENTE
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CLIENTE')
BEGIN
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
END
GO

-- DEPARTAMENTO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DEPARTAMENTO')
BEGIN
    CREATE TABLE DEPARTAMENTO(
        IdDepartamento varchar(5) primary key,
        Descripcion varchar(100)
    );
    PRINT 'Tabla DEPARTAMENTO creada';
END
GO

-- PROVINCIA
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PROVINCIA')
BEGIN
    CREATE TABLE PROVINCIA(
        IdProvincia varchar(5) primary key,
        Descripcion varchar(100),
        IdDepartamento varchar(5) references DEPARTAMENTO(IdDepartamento)
    );
    PRINT 'Tabla PROVINCIA creada';
END
GO

-- DISTRITO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DISTRITO')
BEGIN
    CREATE TABLE DISTRITO(
        IdDistrito varchar(10) primary key,
        Descripcion varchar(100),
        IdProvincia varchar(5) references PROVINCIA(IdProvincia),
        IdDepartamento varchar(5) references DEPARTAMENTO(IdDepartamento)
    );
    PRINT 'Tabla DISTRITO creada';
END
GO

-- CARRITO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CARRITO')
BEGIN
    CREATE TABLE CARRITO(
        IdCarrito int identity(1,1) primary key,
        IdCliente int references CLIENTE(IdCliente),
        IdProducto int references PRODUCTO(IdProducto),
        Cantidad int
    );
    PRINT 'Tabla CARRITO creada';
END
GO

-- VENTA
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VENTA')
BEGIN
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
END
GO

-- DETALLE_VENTA
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DETALLE_VENTA')
BEGIN
    CREATE TABLE DETALLE_VENTA(
        IdDetalleVenta int identity(1,1) primary key,
        IdVenta int references VENTA(IdVenta),
        IdProducto int references PRODUCTO(IdProducto),
        Cantidad int,
        Total decimal(10,2)
    );
    PRINT 'Tabla DETALLE_VENTA creada';
END
GO

-- ====================================================================
-- STORED PROCEDURES
-- ====================================================================

-- SP Registrar Usuario
IF OBJECT_ID('sp_RegistrarUsuario', 'P') IS NOT NULL DROP PROCEDURE sp_RegistrarUsuario;
GO
CREATE PROCEDURE sp_RegistrarUsuario
    @Nombres varchar(100), @Apellidos varchar(100), @Correo varchar(100),
    @Clave varchar(100), @Activo bit,
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM USUARIO WHERE Correo = @Correo)
    BEGIN
        INSERT INTO USUARIO(Nombre, Apellido, Correo, Clave, Reestablecer, Activo)
        VALUES (@Nombres, @Apellidos, @Correo, @Clave, 1, @Activo)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE SET @Mensaje = 'El correo ya existe'
END
GO

-- SP Login Usuario
IF OBJECT_ID('sp_LoginUsuario', 'P') IS NOT NULL DROP PROCEDURE sp_LoginUsuario;
GO
CREATE PROCEDURE sp_LoginUsuario
    @Correo varchar(100), @Clave varchar(100),
    @Resultado int OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    IF EXISTS (SELECT IdUsuario FROM USUARIO WHERE Correo = @Correo AND Clave = @Clave AND Activo = 1)
    BEGIN
        SELECT @Resultado = IdUsuario FROM USUARIO WHERE Correo = @Correo AND Clave = @Clave
    END ELSE SET @Mensaje = 'El correo o la clave no coinciden'
END
GO

-- SP Cambiar Clave
IF OBJECT_ID('sp_CambiarClave', 'P') IS NOT NULL DROP PROCEDURE sp_CambiarClave;
GO
CREATE PROCEDURE sp_CambiarClave
    @IdUsuario int, @NuevaClave varchar(150),
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
AS BEGIN
    SET @Resultado = 0
    UPDATE USUARIO SET Clave = @NuevaClave, Reestablecer = 0 WHERE IdUsuario = @IdUsuario
    SET @Resultado = 1
END
GO

-- SP Reestablecer Clave
IF OBJECT_ID('sp_ReestablecerClave', 'P') IS NOT NULL DROP PROCEDURE sp_ReestablecerClave;
GO
CREATE PROCEDURE sp_ReestablecerClave
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
    END ELSE SET @Mensaje = 'No se encontro un usuario con ese correo'
END
GO

-- SP Registrar Cliente
IF OBJECT_ID('sp_RegistrarCliente', 'P') IS NOT NULL DROP PROCEDURE sp_RegistrarCliente;
GO
CREATE PROCEDURE sp_RegistrarCliente
    @Nombres varchar(100), @Apellidos varchar(100),
    @Correo varchar(100), @Clave varchar(150),
    @Provincia varchar(100),
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM CLIENTE WHERE Correo = @Correo)
    BEGIN
        INSERT INTO CLIENTE(Nombres, Apellidos, Correo, Clave, Provincia)
        VALUES (@Nombres, @Apellidos, @Correo, @Clave, @Provincia)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE SET @Mensaje = 'El correo del cliente ya existe'
END
GO

-- SP Login Cliente
IF OBJECT_ID('sp_LoginCliente', 'P') IS NOT NULL DROP PROCEDURE sp_LoginCliente;
GO
CREATE PROCEDURE sp_LoginCliente
    @Correo varchar(100), @Clave varchar(150),
    @Resultado int OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    IF EXISTS (SELECT IdCliente FROM CLIENTE WHERE Correo = @Correo AND Clave = @Clave)
    BEGIN
        SELECT @Resultado = IdCliente FROM CLIENTE WHERE Correo = @Correo AND Clave = @Clave
    END ELSE SET @Mensaje = 'El correo o la clave no coinciden'
END
GO

-- ====================================================================
-- DATOS INICIALES
-- ====================================================================

-- Limpiar datos existentes
DELETE FROM DETALLE_VENTA;
DELETE FROM VENTA;
DELETE FROM CARRITO;
DELETE FROM PRODUCTO;
DELETE FROM CATEGORIA;
DELETE FROM MARCA;
DBCC CHECKIDENT ('PRODUCTO', RESEED, 0);
DBCC CHECKIDENT ('CATEGORIA', RESEED, 0);
DBCC CHECKIDENT ('MARCA', RESEED, 0);
GO

-- Usuario Admin (clave: admin123)
DECLARE @Mensaje varchar(500), @Resultado int;
EXEC sp_RegistrarUsuario 'Administrador', 'Sistema', 'admin@carrito.com', 'ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae', 1, @Mensaje OUTPUT, @Resultado OUTPUT;
GO

-- Marcas
INSERT INTO MARCA (Descripcion, Activo) VALUES
    ('Samsung', 1), ('Apple', 1), ('LG', 1), ('Sony', 1), ('Xiaomi', 1),
    ('HP', 1), ('Dell', 1), ('Nike', 1), ('Adidas', 1), ('Toyota', 1), ('Honda', 1);
GO

-- Categorias
INSERT INTO CATEGORIA (Descripcion, Activo) VALUES
    ('Electronica', 1), ('Computadoras', 1), ('Telefonia', 1), ('Hogar', 1),
    ('Deportes', 1), ('Moda', 1), ('Automoviles', 1), ('Entretenimiento', 1);
GO

-- Ubicacion Republica Dominicana
DELETE FROM DISTRITO; DELETE FROM PROVINCIA; DELETE FROM DEPARTAMENTO;
GO

INSERT INTO DEPARTAMENTO VALUES
    ('01','Region Norte'), ('02','Region Sur'), ('03','Region Este'),
    ('04','Region Nordeste'), ('05','Region Noroeste'), ('06','Region Sureste'),
    ('07','Region Suroeste'), ('08','Region Metropolitano'), ('09','Region Valdesia'), ('10','Region Yuma');
GO

INSERT INTO PROVINCIA VALUES
    ('0101','Santiago','01'), ('0102','Puerto Plata','01'), ('0103','La Vega','01'),
    ('0104','Espaillat','01'), ('0105','Duarte','01'), ('0201','San Juan','02'),
    ('0202','Barahona','02'), ('0203','Baoruco','02'),
    ('0301','La Altagracia (Punta Cana)','03'), ('0302','La Romana','03'),
    ('0303','San Pedro de Macoris','03'), ('0401','San Cristobal','04'),
    ('0402','Santo Domingo','04'), ('0501','Monte Cristi','05'),
    ('0603','Azua','06'), ('0702','El Seibo','07'),
    ('0801','Distrito Nacional (Santo Domingo)','08'),
    ('0901','San Antonio de Guerra','09'), ('0902','Los Alcarrizos','09'),
    ('1001','Hato Mayor','10'), ('1003','Samana','10');
GO

INSERT INTO DISTRITO VALUES
    ('010101','Santiago Centro','0101','01'), ('010102','La Otra Banda','0101','01'),
    ('010201','Puerto Plata Centro','0102','01'), ('010301','La Vega Centro','0103','01'),
    ('030101','Punta Cana','0301','03'), ('030102','Bavaro','0301','03'),
    ('030201','La Romana Centro','0302','03'),
    ('040201','Santo Domingo Este','0402','04'), ('040202','Santo Domingo Norte','0402','04'),
    ('040203','Santo Domingo Oeste','0402','04'),
    ('080101','Gazcue','0801','08'), ('080102','Zona Colonial','0801','08');
GO

-- Productos
INSERT INTO PRODUCTO (Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, Activo) VALUES
    ('Smart TV 55 Pulgadas 4K','Television inteligente con resolucion 4K Ultra HD',1,1,599.99,25,1),
    ('iPhone 15 Pro Max','Telefono de ultima generacion con camara 48MP',2,3,1199.99,15,1),
    ('Laptop Galaxy Book 3','Laptop Intel Core i7 16GB RAM',1,2,999.99,20,1),
    ('Audifonos Bluetooth Pro','Audifonos inalambricos con cancelacion ruido',4,1,149.99,50,1),
    ('Refrigeradora Smart Inverter','Refrigeradora 22 pies cubicos',3,4,799.99,12,1),
    ('MacBook Air M3','Laptop ultradelgada chip M3 8GB RAM',2,2,1099.99,18,1),
    ('Celular Xiaomi 13 Pro','Smartphone camara Leica carga rapida 120W',5,3,699.99,30,1),
    ('PlayStation 5','Consola de videojuegos ultima generacion',4,8,499.99,10,1),
    ('Zapatillas Nike Air Max','Zapatos deportivos tecnologia Air Max',8,5,129.99,45,1),
    ('Carro Toyota Corolla 2024','Vehiculo sedan compacto eficiente',10,7,25999.99,5,1),
    ('Bicicleta MTB Montain Pro','Bicicleta de montana cuadro aluminio',9,5,399.99,15,1),
    ('Lavadora Automatica 18kg','Lavadora carga frontal 18 programas',3,4,549.99,20,1),
    ('Audifonos AirPods Pro','Audifonos True Wireless con ANC',2,1,249.99,40,1),
    ('Tablet Samsung Galaxy Tab S9','Tablet premium con stylus',1,1,799.99,22,1),
    ('Cocina de Gas 6 Hornillas','Cocina gas acero inoxidable',4,4,349.99,18,1),
    ('Zapatillas Adidas Ultraboost','Zapatillas correr tecnologia Boost',9,5,159.99,35,1),
    ('TV LG OLED 65 Pulgadas','Television OLED negros perfectos 120Hz',3,1,1499.99,8,1),
    ('Honda Civic 2024','Sedan deportivo motor 1.5L turbo',11,7,28999.99,3,1),
    ('Monitor Dell 27 QHD','Monitor profesional resolucion 2560x1440',7,2,349.99,25,1),
    ('Impresora HP LaserJet Pro','Impresora laser monocromatica',6,2,199.99,30,1);
GO

PRINT '';
PRINT '============================================';
PRINT ' INSTALACION COMPLETADA EXITOSAMENTE';
PRINT '============================================';
PRINT '';
PRINT 'DATOS DE ACCESO ADMIN:';
PRINT 'Correo: admin@carrito.com';
PRINT 'Clave: admin123';
PRINT '';
PRINT 'INSTRUCCIONES:';
PRINT '1. Ejecuta CapaPresentacionAdmin para el panel de administracion';
PRINT '2. Ejecuta CapaPresentacionTienda para la tienda de ventas';
PRINT '';
GO
