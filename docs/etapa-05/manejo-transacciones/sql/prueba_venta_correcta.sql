IF OBJECT_ID('sp_RegistrarVenta', 'P') IS NOT NULL
    DROP PROCEDURE sp_RegistrarVenta;
GO

CREATE PROCEDURE sp_RegistrarVenta
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
    DECLARE @v_stock_actual INT;

    -- Calcular el subtotal
    SET @v_subtotal = @p_cantidad * @p_precio_unitario_historico;

    -- Consultar el stock actual ANTES de iniciar la operación
    SELECT @v_stock_actual = stock_actual 
    FROM vino 
    WHERE id_vino = @p_id_vino;

    -- ==========================================
    -- INICIO DE LA TRANSACCION (Atomicidad)
    -- ==========================================
    BEGIN TRANSACTION;

    -- 1. Registrar venta
    INSERT INTO venta (fecha_hora, monto_total, tipo_comprobante, id_cliente, id_usuario)
    VALUES (GETDATE(), @v_subtotal, 'Factura', @p_id_cliente, @p_id_usuario);

    -- Capturar el ID generado
    SET @v_id_venta = SCOPE_IDENTITY();

    -- 2. Registrar detalle
    INSERT INTO detalle_venta (cantidad, precio_unitario_historico, porcentaje_descuento, id_vino, id_venta)
    VALUES (@p_cantidad, @p_precio_unitario_historico, 0, @p_id_vino, @v_id_venta);

    -- 3. Descontar stock
    UPDATE vino
    SET stock_actual = stock_actual - @p_cantidad
    WHERE id_vino = @p_id_vino;

    -- 4. Validación conceptual de stock
    IF @v_stock_actual < @p_cantidad
    BEGIN
        -- No hay stock suficiente: se deshace todo
        ROLLBACK TRANSACTION;
        SELECT 'ROLLBACK: Stock insuficiente. No se registró la venta ni el detalle.' AS resultado, NULL AS id_venta_generada;
    END
    ELSE
    BEGIN
        -- Hay stock suficiente: se confirman los cambios
        COMMIT TRANSACTION;
        SELECT ' COMMIT: Venta registrada y stock actualizado con éxito.' AS resultado, @v_id_venta AS id_venta_generada;
    END
END;
GO

-- Ejecutamos la venta correcta (Pide 10, hay 40)
EXEC sp_RegistrarVenta 
    @p_id_cliente = 1, 
    @p_id_usuario = 1, 
    @p_id_vino = 1, 
    @p_cantidad = 10, 
    @p_precio_unitario_historico = 45000.00;

-- VERIFICACIÓN DE RESULTADOS:
SELECT TOP 1 * 
FROM venta 
ORDER BY id_venta DESC;

SELECT TOP 1 * 
FROM detalle_venta 
ORDER BY id_detalle_venta DESC;

-- Debe retornar 30, porque se descontaron 10 unidades de un stock inicial de 40
SELECT id_vino, nombre, stock_actual 
FROM vino 
WHERE id_vino = 1;