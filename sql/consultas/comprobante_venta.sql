-- 1. FACTURA / COMPROBANTE
SELECT
    v.id_venta,
    v.tipo_comprobante,
    v.fecha_hora,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    CONCAT(u.nombre, ' ', u.apellido) AS vendedor,
    vi.nombre AS producto_vino,
    dv.cantidad,
    dv.precio_unitario_historico,
    dv.porcentaje_descuento,
    -- Cálculo del subtotal por renglón aplicado el descuento
    CAST(
    dv.cantidad * dv.precio_unitario_historico
    * (1 - dv.porcentaje_descuento / 100.0)
    AS DECIMAL(12,2)
) AS subtotal_renglon,
    v.monto_total AS total_acumulado_venta
FROM venta v
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN usuario u ON v.id_usuario = u.id_usuario
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
JOIN vino vi ON dv.id_vino = vi.id_vino
WHERE v.id_venta IN (1, 2, 5); -- Puede cambiar el ID de la venta que se quiera consultar
