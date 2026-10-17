-- 2. REPORTE AGREGADO (GROUP BY, SUM, COUNT)
SELECT 
    cat.nombre_categoria AS categoria_vino,
    COUNT(DISTINCT v.id_venta) AS total_operaciones,
    SUM(dv.cantidad) AS unidades_vendidas,
    CAST(
    SUM(
        dv.cantidad * dv.precio_unitario_historico
        * (1 - dv.porcentaje_descuento / 100.0)
    )
    AS DECIMAL(14,2)
) AS recaudacion_total
FROM categoria cat
JOIN vino vi ON cat.id_categoria = vi.id_categoria
JOIN detalle_venta dv ON vi.id_vino = dv.id_vino
JOIN venta v ON dv.id_venta = v.id_venta
WHERE v.fecha_hora >= '20260201'
  AND v.fecha_hora <  '20260401'
GROUP BY cat.id_categoria, cat.nombre_categoria
ORDER BY recaudacion_total DESC;
