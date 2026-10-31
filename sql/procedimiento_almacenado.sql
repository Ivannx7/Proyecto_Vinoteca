-- 1. Eliminar los procedimientos si ya existen
IF OBJECT_ID('sp_registrar_venta', 'P') IS NOT NULL DROP PROCEDURE sp_registrar_venta;
IF OBJECT_ID('sp_registrar_pago', 'P') IS NOT NULL DROP PROCEDURE sp_registrar_pago;
IF OBJECT_ID('sp_actualizar_stock', 'P') IS NOT NULL DROP PROCEDURE sp_actualizar_stock;
IF OBJECT_ID('sp_actualizar_precio_vino', 'P') IS NOT NULL DROP PROCEDURE sp_actualizar_precio_vino;
IF OBJECT_ID('sp_eliminar_registro', 'P') IS NOT NULL DROP PROCEDURE sp_eliminar_registro;
GO

-- ==========================================
-- PROCEDIMIENTO: sp_registrar_venta
-- ==========================================
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

-- ==========================================
-- PROCEDIMIENTO: sp_registrar_pago
-- ==========================================
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

-- ==========================================
-- PROCEDIMIENTO: sp_actualizar_stock
-- ==========================================
CREATE PROCEDURE sp_actualizar_stock
    @p_id_vino INT,
    @p_cantidad INT -- Puede ser positivo (suma) o negativo (resta)
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

-- ==========================================
-- PROCEDIMIENTO: sp_actualizar_precio_vino
-- ==========================================
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

-- ==========================================
-- PROCEDIMIENTO: sp_eliminar_registro
-- ==========================================
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

    BEGIN TRY
        -- 1. Validar tabla
        SET @v_tabla = LOWER(TRIM(@p_tabla));

        IF @v_tabla IN ('venta', 'detalle_venta', 'venta_pago', 'historial_precio', 'vino_cepa') 
        BEGIN
            RAISERROR('No se permite borrar registros de tablas transaccionales o históricas.', 16, 1);
            RETURN;
        END;

        IF @v_tabla NOT IN ('cepa', 'categoria', 'pais', 'region', 'bodega', 'rol',
                            'metodo_pago', 'cliente', 'usuario', 'vino') 
        BEGIN
            RAISERROR('La tabla indicada no existe o no está habilitada para eliminar registros.', 16, 1);
            RETURN;
        END;

        -- 2. Validar ID
        IF @p_id IS NULL OR @p_id <= 0 
        BEGIN
            RAISERROR('El ID debe ser un número mayor a cero.', 16, 1);
            RETURN;
        END;

        -- 3. Validar que el registro exista (usando SQL Dinámico seguro con sp_executesql)
        SET @v_pk = 'id_' + @v_tabla;
        SET @v_sql = N'SELECT @v_temp_existe_out = COUNT(*) FROM ' + QUOTENAME(@v_tabla) + ' WHERE ' + QUOTENAME(@v_pk) + ' = @id_param';
        
        EXEC sp_executesql @v_sql, 
                           N'@id_param INT, @v_temp_existe_out INT OUTPUT', 
                           @id_param = @p_id, 
                           @v_temp_existe_out = @v_temp_existe OUTPUT;

        IF @v_temp_existe = 0 
        BEGIN
            RAISERROR('No existe un registro con ese ID en la tabla indicada.', 16, 1);
            RETURN;
        END;

        -- 4. Caso especial: un vino con ventas o historial de precios no se puede borrar
        IF @v_tabla = 'vino' 
        BEGIN
            IF EXISTS (SELECT 1 FROM detalle_venta WHERE id_vino = @p_id)
            OR EXISTS (SELECT 1 FROM historial_precio WHERE id_vino = @p_id) 
            BEGIN
                RAISERROR('No se puede eliminar el vino: tiene ventas o historial de precios. Use la baja lógica (estado).', 16, 1);
                RETURN;
            END;

            -- Sus cepas son datos dependientes y se eliminan junto con el vino
            DELETE FROM vino_cepa WHERE id_vino = @p_id;
        END;

        -- 5. Eliminar el registro
        SET @v_sql = N'DELETE FROM ' + QUOTENAME(@v_tabla) + ' WHERE ' + QUOTENAME(@v_pk) + ' = @id_param';
        EXEC sp_executesql @v_sql, N'@id_param INT', @id_param = @p_id;

        -- Retornar resultado exitoso
        SELECT 'Registro eliminado con éxito.' AS resultado,
               @v_tabla AS tabla,
               @p_id AS id_eliminado;

    END TRY
    BEGIN CATCH
        -- Captura errores de llave foránea (Error equivalente en SQL Server: 547)
        IF ERROR_NUMBER() = 547 
        BEGIN
            RAISERROR('No se puede eliminar: el registro está referenciado por otros datos. Considere una baja lógica (estado).', 16, 1);
        END
        ELSE 
        BEGIN
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrorMessage, 16, 1);
        END
    END CATCH
END;
GO

-----------------------------------------------------
-- INVOCACIONES
-----------------------------------------------------
    
-- Venta 1: Vino ID 3 (Colomé Estate Malbec - Precio: $60.000 x 2 = $120.000)
EXEC sp_registrar_venta 3, 1, 3, 2, 60000.00;
EXEC sp_registrar_pago 1, 1, 120000.00;
EXEC sp_actualizar_stock 3, -2; -- Negativo porque es una venta (resta stock)
EXEC sp_actualizar_precio_vino 3, 40000.00, 1;

-- Venta 2: Vino ID 4 (Concha y Toro Cabernet - Precio: $22.000 x 1 = $22.000)
EXEC sp_registrar_venta 1, 1, 4, 1, 22000.00;
EXEC sp_registrar_pago 2, 3, 22000.00;
EXEC sp_actualizar_stock 4, -1;
EXEC sp_actualizar_precio_vino 4, 18000.00, 1;

-- Venta 3: Vino ID 7 (Château Margaux - Precio: $850.000 x 1 = $850.000)
EXEC sp_registrar_venta 7, 1, 7, 1, 850000.00;
EXEC sp_registrar_pago 3, 1, 850000.00;
EXEC sp_actualizar_stock 7, -1;

-- Venta 4: Vino ID 8 (Antinori Toscana Syrah - Precio: $55.000 x 3 = $165.000)
EXEC sp_registrar_venta 8, 1, 8, 3, 55000.00;
EXEC sp_registrar_pago 4, 3, 165000.00;
EXEC sp_actualizar_stock 8, -3;
EXEC sp_actualizar_precio_vino 8, 50000.00, 1;

-- Prueba de eliminación (Intentará borrar la categoría con ID 5)
EXEC sp_eliminar_registro 'categoria', 5;
