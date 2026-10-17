-- 3. CONSULTA DE NEGOCIO AVANZADA (CON SUBCONSULTA Y HAVING)
SELECT 
    r.nombre AS region,
    b.nombre AS bodega,
    COUNT(vi.id_vino) AS variedad_vinos_ofrecidos,
    AVG(CAST(vi.precio_venta AS DECIMAL(10,2))) AS precio_promedio_vinos,
    SUM(dv.cantidad) AS cantidad_vinos_vendidos,
    SUM(dv.cantidad * dv.precio_unitario_historico) AS ingresos_totales_bodega
FROM bodega b
JOIN region r ON b.id_region = r.id_region
JOIN vino vi ON b.id_bodega = vi.id_bodega
JOIN detalle_venta dv ON vi.id_vino = dv.id_vino
WHERE b.id_region IN (
    SELECT id_region 
    FROM region 
    WHERE nombre IN ('Valle del Maipo', 'Canelones', 'Toscana', 'Valle de Uco')
)
GROUP BY r.id_region, r.nombre, b.id_bodega, b.nombre
HAVING SUM(dv.cantidad * dv.precio_unitario_historico) > 50000.00
ORDER BY ingresos_totales_bodega DESC;
