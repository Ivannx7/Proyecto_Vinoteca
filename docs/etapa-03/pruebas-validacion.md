# Pruebas de validación de la base de datos

## 1. Objetivo

Verificar que la base de datos `VINOTECA` se haya implementado correctamente, que los datos iniciales se hayan cargado y que las principales restricciones de integridad se cumplan.

Las pruebas se ejecutan utilizando consultas SQL en Microsoft SQL Server.

## 2. Verificación de las tablas

**Objetivo:** comprobar que existan las 15 tablas previstas en el diseño.

```sql
USE VINOTECA;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

**Resultado esperado:** se deben listar las 15 tablas definidas en el DDL.

## 3. Verificación de la carga inicial

**Objetivo:** comprobar la cantidad de registros insertados en las tablas principales.

```sql
SELECT 'cepa' AS tabla, COUNT(*) AS registros FROM cepa
UNION ALL
SELECT 'categoria', COUNT(*) FROM categoria
UNION ALL
SELECT 'pais', COUNT(*) FROM pais
UNION ALL
SELECT 'rol', COUNT(*) FROM rol
UNION ALL
SELECT 'cliente', COUNT(*) FROM cliente
UNION ALL
SELECT 'metodo_pago', COUNT(*) FROM metodo_pago
UNION ALL
SELECT 'region', COUNT(*) FROM region
UNION ALL
SELECT 'bodega', COUNT(*) FROM bodega
UNION ALL
SELECT 'usuario', COUNT(*) FROM usuario
UNION ALL
SELECT 'vino', COUNT(*) FROM vino
UNION ALL
SELECT 'vino_cepa', COUNT(*) FROM vino_cepa
UNION ALL
SELECT 'venta', COUNT(*) FROM venta
UNION ALL
SELECT 'detalle_venta', COUNT(*) FROM detalle_venta
UNION ALL
SELECT 'historial_precio', COUNT(*) FROM historial_precio
UNION ALL
SELECT 'venta_pago', COUNT(*) FROM venta_pago;
```

**Resultado esperado:** ocho registros por tabla y un total de 120 registros, siempre que las inserciones se hayan ejecutado correctamente en una base vacía.

## 4. Verificación de las relaciones

**Objetivo:** comprobar que los vinos estén asociados a sus categorías y bodegas correspondientes.

```sql
SELECT
    v.id_vino,
    v.nombre AS
 vino,
    c.nombre_categoria AS categoria,
    b.nombre AS bodega
FROM vino AS v
INNER JOIN categoria AS c
    ON v.id_categoria = c.id_categoria
INNER JOIN bodega AS b
    ON v.id_bodega = b.id_bodega;
```

**Resultado esperado:** los vinos deben aparecer asociados a una categoría y una bodega existentes.

## 5. Verificación de las claves foráneas

**Objetivo:** comprobar que los detalles de venta tengan asociadas ventas y vinos existentes.

```sql
SELECT
    dv.id_detalle_venta,
    dv.id_venta,
    dv.id_vino,
    dv.cantidad
FROM detalle_venta AS dv
LEFT JOIN venta AS ve
    ON dv.id_venta = ve.id_venta
LEFT JOIN vino AS vi
    ON dv.id_vino = vi.id_vino
WHERE ve.id_venta IS NULL
   OR vi.id_vino IS NULL;
```

**Resultado esperado:** la consulta no debe devolver registros. Las claves foráneas definidas en el DDL impiden insertar referencias inexistentes mientras las restricciones estén habilitadas.

## 6. Verificación de precios y existencias

**Objetivo:** detectar valores negativos en los precios y las existencias de los vinos.

```sql
SELECT *
FROM vino
WHERE precio_venta < 0
   OR stock_actual < 0
   OR stock_minimo < 0;
```

**Resultado esperado:** la consulta no debe devolver registros.

## 7. Verificación de los importes de venta

**Objetivo:** comparar el importe total de cada venta con el subtotal calculado a partir de sus detalles, aplicando los descuentos registrados.

```sql
SELECT
    v.id_venta,
    v.monto_total,
    SUM(
        CAST(dv.cantidad AS DECIMAL(12,2))
        * dv.precio_unitario_historico
        * (1 - dv.porcentaje_descuento / 100.0)
    ) AS total_calculado
FROM venta AS v
INNER JOIN detalle_venta AS dv
    ON v.id_venta = dv.id_venta
GROUP BY v.id_venta, v.monto_total
HAVING ABS(
    v.monto_total -
    SUM(
        CAST(dv.cantidad AS DECIMAL(12,2))
        * dv.precio_unitario_historico
        * (1 - dv.porcentaje_descuento / 100.0)
    )
) > 0.01;
```

**Resultado esperado:** ninguna venta debería aparecer si sus importes coinciden con los detalles registrados. Esta consulta verifica los importes de las ventas que tienen al menos un detalle.

## 8. Verificación de los pagos

**Objetivo:** comprobar que los pagos registrados coincidan con el total de cada venta.

```sql
SELECT
    v.id_venta,
    v.monto_total,
    COALESCE(SUM(vp.monto), 0) AS total_pagado
FROM venta AS v
LEFT JOIN venta_pago AS vp
    ON v.id_venta = vp.id_venta
GROUP BY v.id_venta, v.monto_total
HAVING ABS(
    v.monto_total - COALESCE(SUM(vp.monto), 0)
) > 0.01;
```

**Resultado esperado:** la consulta no debe devolver registros si todas las ventas están completamente pagadas según los importes registrados.

## 9. Registro de resultados

Una vez ejecutadas las pruebas, se documentarán los resultados obtenidos.

| Prueba                                       | Resultado esperado           | Resultado obtenido |
| -------------------------------------------- | ---------------------------- | ------------------ |
| Existencia de tablas                         | 15 tablas                    | Pendiente          |
| Carga inicial                                | 120 registros                | Pendiente          |
| Relaciones entre vinos, categorías y bodegas | Relaciones válidas           | Pendiente          |
| Integridad referencial en detalles de venta  | Sin referencias inexistentes | Pendiente          |
| Precios y existencias                        | Sin valores negativos        | Pendiente          |
| Consistencia de importes de venta            | Sin diferencias              | Pendiente          |
| Consistencia de pagos                        | Sin diferencias              | Pendiente          |

Los resultados se marcarán como satisfactorios o con observaciones después de ejecutar cada consulta. No se considerará aprobada una prueba hasta comprobar su resultado real.
