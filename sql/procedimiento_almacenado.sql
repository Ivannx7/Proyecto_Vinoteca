-- Eliminar los procedimientos si ya existen para evitar errores de creación
IF OBJECT_ID('sp_RegistrarVenta', 'P') IS NOT NULL DROP PROCEDURE sp_RegistrarVenta;
IF OBJECT_ID('sp_RegistrarPago', 'P') IS NOT NULL DROP PROCEDURE sp_RegistrarPago;
IF OBJECT_ID('sp_ActualizarStock', 'P') IS NOT NULL DROP PROCEDURE sp_ActualizarStock;
GO

---------------------------------------------------------
-- 1. sp_RegistrarVenta
---------------------------------------------------------
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

    SET @v_subtotal = @p_cantidad * @p_precio_unitario_historico;

    -- Insertar la cabecera de la venta
    INSERT INTO venta (fecha_hora, monto_total, tipo_comprobante, id_cliente, id_usuario)
    VALUES (GETDATE(), @v_subtotal, 'Factura', @p_id_cliente, @p_id_usuario);

    -- Obtener el ID generado en la inserción anterior
    SET @v_id_venta = SCOPE_IDENTITY();

    -- Insertar el detalle de la venta
    INSERT INTO detalle_venta (cantidad, precio_unitario_historico, porcentaje_descuento, id_vino, id_venta)
    VALUES (@p_cantidad, @p_precio_unitario_historico, 0, @p_id_vino, @v_id_venta);

    -- Retornar el resultado
    SELECT 'Venta registrada con éxito.' AS resultado, @v_id_venta AS id_venta_generada;
END;
GO

---------------------------------------------------------
-- 2. sp_RegistrarPago
---------------------------------------------------------
CREATE PROCEDURE sp_RegistrarPago
    @p_id_venta INT,
    @p_id_metodo_pago INT,
    @p_monto DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que la venta exista antes de registrar el pago
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
-- 3. sp_ActualizarStock
---------------------------------------------------------
CREATE PROCEDURE sp_ActualizarStock
    @p_id_vino INT,
    @p_cantidad_a_sumar INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_cantidad_a_sumar > 0
    BEGIN
        UPDATE vino 
        SET stock_actual = stock_actual + @p_cantidad_a_sumar
        WHERE id_vino = @p_id_vino;
        
        SELECT 'Stock actualizado correctamente.' AS resultado, 
               stock_actual AS nuevo_stock_actual 
        FROM vino 
        WHERE id_vino = @p_id_vino;
    END
    ELSE
    BEGIN
        SELECT 'Error: La cantidad a sumar debe ser mayor a cero.' AS resultado;
    END
END;
GO
