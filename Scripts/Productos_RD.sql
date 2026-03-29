-- =============================================================
-- Script para agregar productos y provincias de Republica Dominicana
-- =============================================================
USE [DBCARRITO]
GO
-- =====================================
-- LIMPIAR DATOS EXISTENTES
-- =====================================
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
-- =====================================
-- AGREGAR COLUMNA PROVINCIA A CLIENTE
-- =====================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('CLIENTE') AND name = 'Provincia')
BEGIN
    ALTER TABLE CLIENTE ADD Provincia varchar(100) NULL;
END
GO
-- =====================================
-- ACTUALIZAR SP REGISTRO CLIENTE
-- =====================================
CREATE OR ALTER PROC sp_RegistrarCliente(
    @Nombres varchar(100), @Apellidos varchar(100),
    @Correo varchar(100), @Clave varchar(150),
    @Provincia varchar(100),
    @Mensaje varchar(500) OUTPUT, @Resultado int OUTPUT
) AS BEGIN
    SET @Resultado = 0
    IF NOT EXISTS (SELECT * FROM CLIENTE WHERE Correo = @Correo)
    BEGIN
        INSERT INTO CLIENTE(Nombres, Apellidos, Correo, Clave, Provincia)
        VALUES (@Nombres, @Apellidos, @Correo, @Clave, @Provincia)
        SET @Resultado = SCOPE_IDENTITY()
    END ELSE SET @Mensaje = 'El correo del cliente ya existe'
END
GO
-- =====================================
-- ACTUALIZAR UBICACION A RD
-- =====================================
DELETE FROM DISTRITO;
DELETE FROM PROVINCIA;
DELETE FROM DEPARTAMENTO;
GO
INSERT INTO DEPARTAMENTO (IdDepartamento, Descripcion) VALUES
    ('01', 'Region Norte'),
    ('02', 'Region Sur'),
    ('03', 'Region Este'),
    ('04', 'Region Nordeste'),
    ('05', 'Region Noroeste'),
    ('06', 'Region Sureste'),
    ('07', 'Region Suroeste'),
    ('08', 'Region Metropolitano'),
    ('09', 'Region Valdesia'),
    ('10', 'Region Yuma');
GO
INSERT INTO PROVINCIA (IdProvincia, Descripcion, IdDepartamento) VALUES
    ('0101', 'Santiago', '01'),
    ('0102', 'Puerto Plata', '01'),
    ('0103', 'La Vega', '01'),
    ('0104', 'Espaillat', '01'),
    ('0105', 'Duarte', '01'),
    ('0201', 'San Juan', '02'),
    ('0202', 'Barahona', '02'),
    ('0203', 'Baoruco', '02'),
    ('0301', 'La Altagracia (Punta Cana)', '03'),
    ('0302', 'La Romana', '03'),
    ('0303', 'San Pedro de Macoris', '03'),
    ('0401', 'San Cristobal', '04'),
    ('0402', 'Santo Domingo', '04'),
    ('0501', 'Monte Cristi', '05'),
    ('0601', 'San Jose de Ocoa', '06'),
    ('0603', 'Azua', '06'),
    ('0702', 'El Seibo', '07'),
    ('0801', 'Distrito Nacional (Santo Domingo)', '08'),
    ('0901', 'San Antonio de Guerra', '09'),
    ('0902', 'Los Alcarrizos', '09'),
    ('1001', 'Hato Mayor', '10'),
    ('1003', 'Samana', '10');
GO
INSERT INTO DISTRITO (IdDistrito, Descripcion, IdProvincia, IdDepartamento) VALUES
    ('010101', 'Santiago Centro', '0101', '01'),
    ('010102', 'La Otra Banda', '0101', '01'),
    ('010201', 'Puerto Plata Centro', '0102', '01'),
    ('010301', 'La Vega Centro', '0103', '01'),
    ('030101', 'Punta Cana', '0301', '03'),
    ('030102', 'Bavaro', '0301', '03'),
    ('030201', 'La Romana Centro', '0302', '03'),
    ('040201', 'Santo Domingo Este', '0402', '04'),
    ('040202', 'Santo Domingo Norte', '0402', '04'),
    ('040203', 'Santo Domingo Oeste', '0402', '04'),
    ('080101', 'Gazcue', '0801', '08'),
    ('080102', 'Zona Colonial', '0801', '08');
GO
-- =====================================
-- AGREGAR CATEGORIAS
-- =====================================
INSERT INTO CATEGORIA (Descripcion, Activo) VALUES
    ('Electronica', 1),
    ('Computadoras', 1),
    ('Telefonia', 1),
    ('Hogar', 1),
    ('Deportes', 1),
    ('Moda', 1),
    ('Automoviles', 1),
    ('Entretenimiento', 1);
GO
-- =====================================
-- AGREGAR MARCAS
-- =====================================
INSERT INTO MARCA (Descripcion, Activo) VALUES
    ('Samsung', 1),
    ('Apple', 1),
    ('LG', 1),
    ('Sony', 1),
    ('Xiaomi', 1),
    ('HP', 1),
    ('Dell', 1),
    ('Nike', 1),
    ('Adidas', 1),
    ('Toyota', 1),
    ('Honda', 1);
GO
-- =====================================
-- AGREGAR PRODUCTOS
-- =====================================
INSERT INTO PRODUCTO (Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock, Activo) VALUES
    ('Smart TV 55 Pulgadas 4K', 'Television inteligente con resolucion 4K Ultra HD y HDR', 1, 1, 599.99, 25, 1),
    ('iPhone 15 Pro Max', 'Telefono de ultima generacion con camara de 48MP', 2, 3, 1199.99, 15, 1),
    ('Laptop Galaxy Book 3', 'Laptop con procesador Intel Core i7 y 16GB RAM', 1, 2, 999.99, 20, 1),
    ('Audifonos Bluetooth Pro', 'Audifonos inalambricos con cancelacion de ruido', 4, 1, 149.99, 50, 1),
    ('Refrigeradora Smart Inverter', 'Refrigeradora de 22 pies cubicos con tecnologia inverter', 3, 4, 799.99, 12, 1),
    ('MacBook Air M3', 'Laptop ultradelgada con chip M3, 8GB RAM', 2, 2, 1099.99, 18, 1),
    ('Celular Xiaomi 13 Pro', 'Smartphone con camara Leica y carga rapida 120W', 5, 3, 699.99, 30, 1),
    ('PlayStation 5', 'Consola de videojuegos de ultima generacion', 4, 8, 499.99, 10, 1),
    ('Zapatillas Nike Air Max', 'Zapatos deportivos con tecnologia Air Max', 8, 5, 129.99, 45, 1),
    ('Carro Toyota Corolla 2024', 'Vehiculo sedan compacto, eficiente y seguro', 10, 7, 25999.99, 5, 1),
    ('Bicicleta MTB Montain Pro', 'Bicicleta de montana con cuadro de aluminio', 9, 5, 399.99, 15, 1),
    ('Lavadora Automatica 18kg', 'Lavadora de carga frontal con 18 programas', 3, 4, 549.99, 20, 1),
    ('Audifonos AirPods Pro', 'Audifonos True Wireless con ANC', 2, 1, 249.99, 40, 1),
    ('Tablet Samsung Galaxy Tab S9', 'Tablet premium con stylus incluido', 1, 1, 799.99, 22, 1),
    ('Cocina de Gas 6 Hornillas', 'Cocina a gas de acero inoxidable con horno', 4, 4, 349.99, 18, 1),
    ('Zapatillas Adidas Ultraboost', 'Zapatillas para correr con tecnologia Boost', 9, 5, 159.99, 35, 1),
    ('TV LG OLED 65 Pulgadas', 'Television OLED con negros perfectos y 120Hz', 3, 1, 1499.99, 8, 1),
    ('Honda Civic 2024', 'Sedan deportivo con motor 1.5L turbo', 11, 7, 28999.99, 3, 1),
    ('Monitor Dell 27 Pulgadas QHD', 'Monitor profesional con resolucion 2560x1440', 7, 2, 349.99, 25, 1),
    ('Impresora HP LaserJet Pro', 'Impresora laser monocromatica de alta velocidad', 6, 2, 199.99, 30, 1);
GO
PRINT 'Productos y ubicaciones de Republica Dominicana agregados correctamente';