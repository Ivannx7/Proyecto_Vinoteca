# Consulta de comprobante de venta

## 1. Objetivo

Obtener una vista consolidada del encabezado y el detalle de una venta.
La consulta muestra los datos del comprobante, el cliente, el vendedor y
los vinos incluidos, junto con cantidades, precios históricos,
descuentos, subtotales por renglón y total acumulado de la operación.

## 2. Script SQL

``` sql
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
```

## 3. Tablas involucradas

-   **`venta`:** contiene los datos generales de la operación, como
    identificador, tipo de comprobante, fecha y total.
-   **`cliente`:** permite obtener el nombre y apellido del cliente.
-   **`usuario`:** identifica al usuario responsable de registrar la
    venta.
-   **`detalle_venta`:** contiene los vinos vendidos, las cantidades,
    los precios históricos y los descuentos.
-   **`vino`:** proporciona el nombre del producto vendido.

La consulta utiliza `JOIN`, equivalente a `INNER JOIN` en este caso. Por
eso, solo aparecen ventas que tengan coincidencias en todas las tablas
relacionadas.

## 4. Cálculo del subtotal por renglón

El subtotal se calcula aplicando la cantidad, el precio unitario
histórico y el descuento:

``` sql
cantidad * precio_unitario_historico
* (1 - porcentaje_descuento / 100.0)
```

Por ejemplo, si se venden 2 unidades a $10.000 cada una y se aplica un
descuento del 10 %, el subtotal del renglón es $18.000.

Se utiliza `100.0` para realizar la operación con decimales y
`CAST(... AS DECIMAL(12,2))` para expresar el importe con dos posiciones
decimales.

## 5. Interpretación del resultado

La consulta devuelve una fila por cada vino incluido en las ventas
seleccionadas. Por lo tanto, los datos del encabezado ---incluido
`total_acumulado_venta`--- se repiten si una venta contiene varios
productos.

El campo `total_acumulado_venta` muestra el valor almacenado en
`venta.monto_total`; no se calcula nuevamente en esta consulta. La suma
de los subtotales debería coincidir con ese valor si ambos utilizan las
mismas reglas de descuento, redondeo y cargos adicionales.

