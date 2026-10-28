-- Ejecutamos la venta incorrecta (Pide 100, hay 40)
EXEC sp_RegistrarVenta 
    @p_id_cliente = 1, 
    @p_id_usuario = 1, 
    @p_id_vino = 1, 
    @p_cantidad = 100, 
    @p_precio_unitario_historico = 45000.00;

-- VERIFICACIÓN DE RESULTADOS:
SELECT TOP 1 * FROM venta ORDER BY venta_id DESC;
SELECT TOP 1 * FROM detalle_venta ORDER BY detalle_venta_id DESC;

-- Debe retornar 40 (Demostrando que el Rollback deshizo los inserts y protegio el stock)
SELECT vino_id, nombre_vino, stock_actual FROM vino WHERE vino_id = 1;