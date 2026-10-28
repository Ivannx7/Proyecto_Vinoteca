# Informe agregado de ventas por categoría

## 1. Objetivo

Obtener un resumen de las ventas por categoría de vino dentro de un
período determinado. El informe permite comparar el número de
operaciones, las unidades vendidas y la recaudación calculada para cada
categoría.

## 2. Script SQL

``` sql
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
```

## 3. Tablas involucradas

-   **`categoria`:** identifica la categoría a la que pertenece cada
    vino.
-   **`vino`:** relaciona los vinos con su categoría.
-   **`detalle_venta`:** aporta las cantidades, los precios históricos y
    los descuentos aplicados.
-   **`venta`:** permite limitar el informe a un período de fechas.

## 4. Período analizado

El filtro incluye las ventas desde el **1 de febrero de 2026** inclusive
hasta antes del **1 de abril de 2026**. De esta manera, se consideran
febrero y marzo completos, incluso si `fecha_hora` almacena horas y
minutos.

El formato de fecha `YYYYMMDD` se utiliza para que SQL Server interprete
los literales de forma clara.

## 5. Métricas calculadas

-   **`total_operaciones`:** cuenta las ventas distintas asociadas a
    cada categoría. Si una venta contiene varios vinos de la misma
    categoría, se cuenta una sola vez dentro de esa categoría.
-   **`unidades_vendidas`:** suma las cantidades registradas en los
    detalles de venta.
-   **`recaudacion_total`:** suma los importes calculados con los
    precios históricos y los descuentos.
-   **`ORDER BY recaudacion_total DESC`:** ordena las categorías desde
    la de mayor recaudación hasta la menor.

La cláusula `GROUP BY` agrupa los registros por identificador y nombre
de categoría. Luego, `SUM` y `COUNT(DISTINCT ...)` calculan las métricas
para cada grupo.
