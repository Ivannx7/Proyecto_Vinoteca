-- 1. ELIMINACIÓN DE OBJETOS EXISTENTES (SI YA ESTÁN CREADOS)
IF OBJECT_ID('sp_registrar_venta', 'P') IS NOT NULL DROP PROCEDURE sp_registrar_venta;
IF OBJECT_ID('sp_registrar_pago', 'P') IS NOT NULL DROP PROCEDURE sp_registrar_pago;
IF OBJECT_ID('sp_actualizar_stock', 'P') IS NOT NULL DROP PROCEDURE sp_actualizar_stock;
IF OBJECT_ID('sp_actualizar_precio_vino', 'P') IS NOT NULL DROP PROCEDURE sp_actualizar_precio_vino;
IF OBJECT_ID('sp_eliminar_registro', 'P') IS NOT NULL DROP PROCEDURE sp_eliminar_registro;
GO

-- =====================================================================
-- 2. CREACIÓN DE PROCEDIMIENTOS ALMACENADOS
-- =====================================================================

---------------------------------------------------------
-- 1. sp_registrar_venta
--   Registra una nueva venta en el sistema junto con su detalle,
--   calculando el subtotal y generando los IDs correspondientes.
---------------------------------------------------------
CREATE PROCEDURE sp_registrar_venta
    @p_id_cliente INT,
    @p_id_usuario INT,
    @p_id_vino INT,
    @p_cantidad INT,
    @p_precio_unitario_historico DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_id_venta INT;
    DECLARE @v_subtotal DECIMAL(12,2);

    SET @v_subtotal = @p_cantidad * @p_precio_unitario_historico;

    INSERT INTO venta (fecha_hora, monto_total, tipo_comprobante, id_cliente, id_usuario)
    VALUES (GETDATE(), @v_subtotal, 'Factura', @p_id_cliente, @p_id_usuario);

    SET @v_id_venta = SCOPE_IDENTITY();

    INSERT INTO detalle_venta (cantidad, precio_unitario_historico, porcentaje_descuento, id_vino, id_venta)
    VALUES (@p_cantidad, @p_precio_unitario_historico, 0, @p_id_vino, @v_id_venta);

    SELECT 'Venta registrada con éxito.' AS resultado, @v_id_venta AS id_venta_generada;
END;
GO

---------------------------------------------------------
-- 2. sp_registrar_pago
--   Registra un pago asociado a una venta existente en el sistema.
---------------------------------------------------------
CREATE PROCEDURE sp_registrar_pago
    @p_id_venta INT,
    @p_id_metodo_pago INT,
    @p_monto DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM venta WHERE id_venta = @p_id_venta) 
    BEGIN
        INSERT INTO venta_pago (fecha_hora, monto, id_venta, id_metodo_pago)
        VALUES (GETDATE(), @p_monto, @p_id_venta, @p_id_metodo_pago);
        
        SELECT 'Pago registrado con éxito.' AS resultado, SCOPE_IDENTITY() AS id_pago_generado;
    END
    ELSE
    BEGIN
        SELECT 'Error: La venta especificada no existe.' AS resultado;
    END
END;
GO

---------------------------------------------------------
-- 3. sp_actualizar_stock
--   Actualiza la cantidad de stock actual de un vino específico.
---------------------------------------------------------
CREATE PROCEDURE sp_actualizar_stock
    @p_id_vino INT,
    @p_cantidad INT
AS
BEGIN
    SET NOCOUNT ON;
    IF @p_cantidad = 0 
    BEGIN
        SELECT 'Error: La cantidad no puede ser cero.' AS resultado;
    END
    ELSE
    BEGIN
        UPDATE vino 
        SET stock_actual = stock_actual + @p_cantidad
        WHERE id_vino = @p_id_vino;
        
        SELECT 'Stock actualizado correctamente.' AS resultado, 
               stock_actual AS nuevo_stock_actual 
        FROM vino 
        WHERE id_vino = @p_id_vino;
    END
END;
GO

---------------------------------------------------------
-- 4. sp_actualizar_precio_vino
--   Registra el cambio de precio de un vino en el historial y lo actualiza.
---------------------------------------------------------
CREATE PROCEDURE sp_actualizar_precio_vino
    @p_id_vino INT,
    @p_nuevo_precio DECIMAL(10,2),
    @p_id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO historial_precio (fecha_vigencia, precio_nuevo, precio_anterior, id_usuario, id_vino, id_detalle_venta)
    SELECT GETDATE(), @p_nuevo_precio, precio_venta, @p_id_usuario, id_vino, NULL
    FROM vino
    WHERE id_vino = @p_id_vino;

    UPDATE vino
    SET precio_venta = @p_nuevo_precio
    WHERE id_vino = @p_id_vino;

    SELECT 'Precio actualizado correctamente y registrado en el historial.' AS resultado;
END;
GO

---------------------------------------------------------
-- 5. sp_eliminar_registro
--   Borra un registro (por su ID) de una tabla permitida.
---------------------------------------------------------
CREATE PROCEDURE sp_eliminar_registro
    @p_tabla VARCHAR(128),
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_tabla VARCHAR(128);
    DECLARE @v_pk VARCHAR(128);
    DECLARE @v_sql NVARCHAR(MAX);
    DECLARE @v_temp_existe INT;

    SET @v_tabla = LOWER(LTRIM(RTRIM(@p_tabla)));

    IF @v_tabla IN ('venta', 'detalle_venta', 'venta_pago', 'historial_precio', 'vino_cepa') 
    BEGIN
        THROW 50000, 'No se permite borrar registros de tablas transaccionales o históricas.', 1;
        RETURN;
    END;

    IF @v_tabla NOT IN ('cepa', 'categoria', 'pais', 'region', 'bodega', 'rol',
                        'metodo_pago', 'cliente', 'usuario', 'vino') 
    BEGIN
        THROW 50001, 'La tabla indicada no existe o no está habilitada para eliminar registros.', 1;
        RETURN;
    END;

    IF @p_id IS NULL OR @p_id <= 0 
    BEGIN
        THROW 50002, 'El ID debe ser un número mayor a cero.', 1;
        RETURN;
    END;

    SET @v_pk = 'id_' + @v_tabla;
    SET @v_sql = N'SELECT @v_temp_existe_out = COUNT(*) FROM ' + QUOTENAME(@v_tabla) + ' WHERE ' + QUOTENAME(@v_pk) + ' = @p_id_val';
    
    EXEC sp_executesql @v_sql, 
         N'@p_id_val INT, @v_temp_existe_out INT OUTPUT', 
         @p_id_val = @p_id, 
         @v_temp_existe_out = @v_temp_existe OUTPUT;

    IF @v_temp_existe = 0 
    BEGIN
        THROW 50003, 'No existe un registro con ese ID en la tabla indicada.', 1;
        RETURN;
    END;

    IF @v_tabla = 'vino' 
    BEGIN
        IF EXISTS (SELECT 1 FROM detalle_venta WHERE id_vino = @p_id)
        OR EXISTS (SELECT 1 FROM historial_precio WHERE id_vino = @p_id) 
        BEGIN
            THROW 50004, 'No se puede eliminar el vino: tiene ventas o historial de precios. Use la baja lógica (estado).', 1;
            RETURN;
        END;

        DELETE FROM vino_cepa WHERE id_vino = @p_id;
    END;

    BEGIN TRY
        SET @v_sql = N'DELETE FROM ' + QUOTENAME(@v_tabla) + ' WHERE ' + QUOTENAME(@v_pk) + ' = @p_id_val';
        EXEC sp_executesql @v_sql, N'@p_id_val INT', @p_id_val = @p_id;

        SELECT 'Registro eliminado con éxito.' AS resultado,
               @v_tabla AS tabla,
               @p_id AS id_eliminado;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 547
        BEGIN
            THROW 50005, 'No se puede eliminar: el registro está referenciado por otros datos. Considere una baja lógica (estado).', 1;
        END
        ELSE
        BEGIN
            THROW;
        END
    END CATCH;
END;
GO

-- =====================================================================
-- 3. SCRIPT DE PRUEBAS Y DEMOSTRACIÓN EN SQL SERVER EXPRESS
-- =====================================================================

-- Venta 1: Vino ID 3 (Colomé Estate Malbec - Precio: $60.000 x 2 = $120.000)
EXEC sp_registrar_venta @p_id_cliente = 3, @p_id_usuario = 1, @p_id_vino = 3, @p_cantidad = 2, @p_precio_unitario_historico = 60000.00;
EXEC sp_registrar_pago @p_id_venta = 1, @p_id_metodo_pago = 1, @p_monto = 120000.00;
EXEC sp_actualizar_stock @p_id_vino = 3, @p_cantidad = 2;
EXEC sp_actualizar_precio_vino @p_id_vino = 3, @p_nuevo_precio = 40000.00, @p_id_usuario = 1;

-- Venta 2: Vino ID 4 (Concha y Toro Cabernet - Precio: $22.000 x 1 = $22.000)
EXEC sp_registrar_venta @p_id_cliente = 1, @p_id_usuario = 1, @p_id_vino = 4, @p_cantidad = 1, @p_precio_unitario_historico = 22000.00;
EXEC sp_registrar_pago @p_id_venta = 2, @p_id_metodo_pago = 3, @p_monto = 22000.00;
EXEC sp_actualizar_stock @p_id_vino = 4, @p_cantidad = 1;
EXEC sp_actualizar_precio_vino @p_id_vino = 4, @p_nuevo_precio = 18000.00, @p_id_usuario = 1;

-- Venta 3: Vino ID 7 (Château Margaux - Precio: $850.000 x 1 = $850.000)
EXEC sp_registrar_venta @p_id_cliente = 7, @p_id_usuario = 1, @p_id_vino = 7, @p_cantidad = 1, @p_precio_unitario_historico = 850000.00;
EXEC sp_registrar_pago @p_id_venta = 3, @p_id_metodo_pago = 1, @p_monto = 850000.00;
EXEC sp_actualizar_stock @p_id_vino = 7, @p_cantidad = 1;
EXEC sp_actualizar_precio_vino @p_id_vino = 7, @p_nuevo_precio = 820000.00, @p_id_usuario = 1; -- Cuarta actualización agregada

-- Venta 4: Vino ID 8 (Antinori Toscana Syrah - Precio: $55.000 x 3 = $165.000)
EXEC sp_registrar_venta @p_id_cliente = 8, @p_id_usuario = 1, @p_id_vino = 8, @p_cantidad = 3, @p_precio_unitario_historico = 55000.00;
EXEC sp_registrar_pago @p_id_venta = 4, @p_id_metodo_pago = 3, @p_monto = 165000.00;
EXEC sp_actualizar_stock @p_id_vino = 8, @p_cantidad = 3;
EXEC sp_actualizar_precio_vino @p_id_vino = 8, @p_nuevo_precio = 50000.00, @p_id_usuario = 1;

-- Prueba de eliminación de registro permitido
EXEC sp_eliminar_registro @p_tabla = 'categoria', @p_id = 5;
GO