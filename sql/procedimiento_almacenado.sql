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
