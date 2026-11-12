-- Ejecutamos la venta incorrecta (Pide 100, hay 40)
EXEC sp_RegistrarVenta 
    @p_id_cliente = 1, 
    @p_id_usuario = 1, 
    @p_id_vino = 1, 
    @p_cantidad = 100, 
    @p_precio_unitario_historico = 45000.00;

-- VERIFICACIÓN DE RESULTADOS:
SELECT TOP 1 * FROM venta ORDER BY id_venta DESC;
SELECT TOP 1 * FROM detalle_venta ORDER BY id_detalle_venta DESC;

-- Debe retornar 40 (Demostrando que el Rollback deshizo los inserts y protegio el stock)
SELECT id_vino, nombre, stock_actual FROM vino WHERE id_vino = 1;