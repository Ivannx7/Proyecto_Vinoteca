# Consulta de negocio avanzada: análisis por bodega y región

## 1. Objetivo

Analizar la oferta de vinos y los ingresos generados por las bodegas
ubicadas en determinadas regiones. La consulta combina varias tablas
mediante `JOIN`, selecciona regiones a través de una subconsulta y
aplica `HAVING` para mostrar únicamente los grupos cuyos ingresos
calculados superan los $50.000.

## 2. Script SQL

``` sql
SELECT 
    r.nombre AS region,
    b.nombre AS bodega,
    COUNT(DISTINCT vi.id_vino) AS variedad_vinos_ofrecidos,
    CAST(
    AVG(vi.precio_venta)
    AS DECIMAL(12,2)
) AS precio_promedio_vinos,
    SUM(dv.cantidad) AS cantidad_vinos_vendidos,
   CAST(
    SUM(
        dv.cantidad * dv.precio_unitario_historico
        * (1 - dv.porcentaje_descuento / 100.0)
    )
    AS DECIMAL(14,2)
) AS ingresos_totales_bodega
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
HAVING SUM(
    dv.cantidad * dv.precio_unitario_historico
    * (1 - dv.porcentaje_descuento / 100.0)) > 50000.00
ORDER BY ingresos_totales_bodega DESC;

```

## 3. Tablas involucradas**

-   **`region`:** aporta el nombre de la región.
-   **`bodega`:** identifica cada bodega y su región.
-   **`vino`:** relaciona los vinos con su bodega y aporta el precio de
    venta actual.
-   **`detalle_venta`:** aporta las unidades vendidas, los precios
    históricos y los descuentos.

La consulta relaciona cuatro tablas mediante `JOIN` y utiliza una
subconsulta para filtrar las regiones.

## 4. Funcionamiento de la subconsulta

La subconsulta obtiene los identificadores de las regiones cuyos nombres
coinciden con `Valle del Maipo`, `Canelones`, `Toscana` o
`Valle de Uco`.

La condición `b.id_region IN (...)` limita el análisis a las bodegas
pertenecientes a esas regiones. Los nombres deben coincidir con los
valores almacenados en la tabla `region`.

## 5. Agrupación y condición HAVING

La cláusula `GROUP BY` agrupa los registros por región y bodega.

-   **`COUNT(DISTINCT vi.id_vino)`:** cuenta los vinos distintos que
    aparecen en los registros de venta del grupo.
-   **`AVG(vi.precio_venta)`:** calcula el precio promedio actual de los
    vinos incluidos en el grupo.
-   **`SUM(dv.cantidad)`:** suma las unidades vendidas.
-   **`SUM(...)`:** calcula los ingresos aplicando el precio histórico y
    el descuento.
-   **`HAVING ... > 50000.00`:** conserva únicamente los grupos cuyo
    ingreso calculado supera los \$50.000.
-   **`ORDER BY ingresos_totales_bodega DESC`:** ordena las bodegas de
    mayor a menor ingreso calculado.

A diferencia de `WHERE`, que filtra filas antes de la agrupación,
`HAVING` filtra los grupos después de calcular las agregaciones.

## 6. Consideraciones sobre el alcance

El script original no relaciona la tabla `venta`, por lo que no permite
limitar el análisis por fecha ni por estado de la operación. Además,
como utiliza `INNER JOIN` con `detalle_venta`, solo considera vinos que
tienen detalles de venta.

Si se necesita analizar las ventas de un período específico, se puede
agregar la relación con `venta` después del `JOIN` con `detalle_venta`:

``` sql
JOIN venta v ON dv.id_venta = v.id_venta
```

Luego, se debe incorporar al `WHERE` un rango de fechas apropiado. Si el
sistema distingue ventas confirmadas, pendientes o anuladas, también
debe definirse qué estados se incluyen.



