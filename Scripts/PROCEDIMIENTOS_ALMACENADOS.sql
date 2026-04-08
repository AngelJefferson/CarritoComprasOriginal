-- ================================================================
-- TODOS LOS STORED PROCEDURES - CARRITO DE COMPRAS
-- Compatible con: SQL Server 2012 en adelante
-- ================================================================

USE DBCARRITOTEST;
GO

-- ================================================================
-- STORED PROCEDURES - USUARIOS
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

-- ================================================================
-- STORED PROCEDURES - MARCAS
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

-- ================================================================
-- STORED PROCEDURES - CATEGORIAS
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

-- ================================================================
-- STORED PROCEDURES - PRODUCTOS
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

-- ================================================================
-- STORED PROCEDURES - CLIENTES
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

-- ================================================================
-- STORED PROCEDURES - CARRITO
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

-- SP Contar Carrito
IF OBJECT_ID('SP_ContarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_ContarCarrito;
GO
CREATE PROCEDURE SP_ContarCarrito
    @IdCliente int, @Resultado int OUTPUT
AS BEGIN
    SELECT @Resultado = ISNULL(SUM(Cantidad), 0) FROM CARRITO WHERE IdCliente = @IdCliente
END
GO

-- SP Limpiar Carrito
IF OBJECT_ID('SP_LimpiarCarrito', 'P') IS NOT NULL DROP PROCEDURE SP_LimpiarCarrito;
GO
CREATE PROCEDURE SP_LimpiarCarrito
    @IdCliente int,
    @Resultado bit OUTPUT, @Mensaje varchar(500) OUTPUT
AS BEGIN
    SET @Resultado = 0
    DELETE FROM CARRITO WHERE IdCliente = @IdCliente
    SET @Resultado = 1
END
GO

-- SP Listar Producto
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

-- SP Listar Producto Tienda
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
-- STORED PROCEDURES - UBICACION
-- ================================================================

-- SP Obtener Departamentos
IF OBJECT_ID('SP_ObtenerDepartamentos', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerDepartamentos;
GO
CREATE PROCEDURE SP_ObtenerDepartamentos
AS BEGIN
    SELECT IdDepartamento, Descripcion FROM DEPARTAMENTO ORDER BY Descripcion
END
GO

-- SP Obtener Provincias
IF OBJECT_ID('SP_ObtenerProvincias', 'P') IS NOT NULL DROP PROCEDURE SP_ObtenerProvincias;
GO
CREATE PROCEDURE SP_ObtenerProvincias
    @IdDepartamento varchar(5)
AS BEGIN
    SELECT IdProvincia, Descripcion FROM PROVINCIA WHERE IdDepartamento = @IdDepartamento ORDER BY Descripcion
END
GO

-- SP Obtener Distritos
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

PRINT '';
PRINT '============================================';
PRINT ' 29 STORED PROCEDURES CREADOS';
PRINT '============================================';
GO
