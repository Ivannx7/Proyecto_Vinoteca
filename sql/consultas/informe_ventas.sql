-- 2. REPORTE AGREGADO (GROUP BY, SUM, COUNT)
SELECT 
    cat.nombre_categoria AS categoria_vino,
    COUNT(DISTINCT v.id_venta) AS total_operaciones,
    SUM(dv.cantidad) AS unidades_vendidas,
    SUM(dv.cantidad * dv.precio_unitario_historico * (1 - CAST(dv.porcentaje_descuento AS DECIMAL(5,2)) / 100)) AS recaudacion_total
FROM categoria cat
JOIN vino vi ON cat.id_categoria = vi.id_categoria
JOIN detalle_venta dv ON vi.id_vino = dv.id_vino
JOIN venta v ON dv.id_venta = v.id_venta
WHERE v.fecha_hora 
BETWEEN '2026-02-01T00:00:00' AND '2026-03-31T23:59:59' -- Formato seguro ISO para SQL Server
GROUP BY cat.id_categoria, cat.nombre_categoria
ORDER BY recaudacion_total DESC;
