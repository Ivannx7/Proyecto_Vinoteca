# Funciones y casos de prueba -- VINOTECA

## 1. Introducción

Se documentan las funciones escalares desarrolladas en SQL Server para
la base de datos VINOTECA. Cada una incluye su objetivo, código y una
consulta para comprobar su funcionamiento.

En las pruebas, `OK` indica que el resultado de la función coincide con
el esperado; `ERROR` señala una diferencia.

------------------------------------------------------------------------

## 2. `fn_SaldoPendiente`

**Objetivo:** calcular cuánto queda por pagar de una venta, restando los
pagos realizados al monto total. Si no existen pagos, se considera que
el total pagado es cero.

**Código:**

``` sql
CREATE OR ALTER FUNCTION dbo.fn_SaldoPendiente (
    @p_id_venta INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @v_saldo DECIMAL(12,2);

    SELECT
        @v_saldo = v.monto_total -
            ISNULL((
                SELECT SUM(vp.monto)
                FROM venta_pago vp
                WHERE vp.id_venta = v.id_venta
            ), 0)
    FROM venta v
    WHERE v.id_venta = @p_id_venta;

    RETURN @v_saldo;
END;
GO
```

**Explicación:** recibe el ID de una venta, suma sus pagos con `SUM`,
reemplaza por cero la ausencia de pagos mediante `ISNULL` y devuelve la
diferencia. Si la venta no existe, devuelve `NULL`.

### Prueba: saldo de las ventas

``` sql
SELECT
    v.id_venta,
    v.monto_total,
    ISNULL(SUM(vp.monto), 0) AS total_pagado,
    dbo.fn_SaldoPendiente(v.id_venta) AS saldo_restante,
    CASE
        WHEN dbo.fn_SaldoPendiente(v.id_venta) =
             v.monto_total - ISNULL(SUM(vp.monto), 0)
        THEN 'OK' ELSE 'ERROR'
    END AS resultado
FROM venta v
LEFT JOIN venta_pago vp ON vp.id_venta = v.id_venta
GROUP BY v.id_venta, v.monto_total
ORDER BY v.id_venta;
GO
```

**Verificación:** compara el saldo de la función con el cálculo directo
del monto total menos los pagos.

**Captura del resultado:**

(image.png) --> en carpeta de imagenes-caso-de-prueba/ img-funciones

------------------------------------------------------------------------

## 3. `fn_CalcularDescuento`

**Objetivo:** calcular el porcentaje de descuento de un cliente según el
monto acumulado de sus ventas.

  Acumulado                               Descuento
  ------------------------------------- -----------
  Mayor a \$600.000                            10 %
  Mayor a \$300.000 y hasta \$600.000           5 %
  Hasta \$300.000                               0 %

**Código:**

``` sql
CREATE OR ALTER FUNCTION dbo.fn_CalcularDescuento (
    @p_id_cliente INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @v_acumulado DECIMAL(14,2);

    SELECT
        @v_acumulado = ISNULL(SUM(monto_total), 0)
    FROM venta
    WHERE id_cliente = @p_id_cliente;

    RETURN
        CASE
            WHEN @v_acumulado > 600000 THEN 10.00
            WHEN @v_acumulado > 300000 THEN 5.00
            ELSE 0.00
        END;
END;
GO
```

**Explicación:** suma los montos de las ventas del cliente y utiliza
`CASE` para determinar el descuento. Si no tiene ventas, devuelve 0 %.

### Prueba: descuento por cliente

``` sql
SELECT
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS cliente,
    ISNULL(SUM(v.monto_total), 0) AS acumulado,
    dbo.fn_CalcularDescuento(c.id_cliente) AS descuento_pct,
    CASE
        WHEN dbo.fn_CalcularDescuento(c.id_cliente) =
             CASE
                 WHEN ISNULL(SUM(v.monto_total), 0) > 600000 THEN 10.00
                 WHEN ISNULL(SUM(v.monto_total), 0) > 300000 THEN 5.00
                 ELSE 0.00
             END
        THEN 'OK' ELSE 'ERROR'
    END AS resultado
FROM cliente c
LEFT JOIN venta v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY c.id_cliente;
GO
```

**Verificación:** compara el descuento de la función con el porcentaje
calculado independientemente mediante `CASE`.

**Captura del resultado:**

(image-1.png) --> en carpeta de imagenes-caso-de-prueba/ img-funciones

------------------------------------------------------------------------

## 4. `fn_EdadCliente`

**Objetivo:** calcular la edad del cliente en años cumplidos, teniendo
en cuenta si ya pasó su cumpleaños en el año actual.

**Código:**

``` sql
CREATE OR ALTER FUNCTION dbo.fn_EdadCliente (
    @p_id_cliente INT
)
RETURNS INT
AS
BEGIN
    DECLARE @v_nacimiento DATE;
    DECLARE @v_hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @v_edad INT;

    SELECT @v_nacimiento = fecha_nacimiento
    FROM cliente
    WHERE id_cliente = @p_id_cliente;

    IF @v_nacimiento IS NULL
        RETURN NULL;

    SET @v_edad = DATEDIFF(YEAR, @v_nacimiento, @v_hoy);

    IF DATEADD(YEAR, @v_edad, @v_nacimiento) > @v_hoy
        SET @v_edad = @v_edad - 1;

    RETURN @v_edad;
END;
GO
```

**Explicación:** obtiene la fecha de nacimiento y calcula la diferencia
de años con `DATEDIFF`. Luego utiliza `DATEADD` para comprobar si el
cumpleaños ya ocurrió. Si todavía no ocurrió, resta un año. Si no
encuentra una fecha de nacimiento, devuelve `NULL`.

### Prueba: edad y mayoría de edad

``` sql
SELECT
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS cliente,
    c.fecha_nacimiento,
    dbo.fn_EdadCliente(c.id_cliente) AS edad_funcion,
    CASE
        WHEN c.fecha_nacimiento IS NULL THEN 'SIN DATOS'
        WHEN dbo.fn_EdadCliente(c.id_cliente) >= 18 THEN 'SI'
        ELSE 'NO'
    END AS puede_comprar_alcohol,
    CASE
        WHEN c.fecha_nacimiento IS NULL
             AND dbo.fn_EdadCliente(c.id_cliente) IS NULL THEN 'OK'
        WHEN dbo.fn_EdadCliente(c.id_cliente) =
             DATEDIFF(YEAR, c.fecha_nacimiento, GETDATE())
             - CASE
                   WHEN DATEADD(
                       YEAR,
                       DATEDIFF(YEAR, c.fecha_nacimiento, GETDATE()),
                       c.fecha_nacimiento
                   ) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END
        THEN 'OK' ELSE 'ERROR'
    END AS resultado
FROM cliente c
ORDER BY c.id_cliente;
GO
```

**Verificación:** compara la edad calculada por la función con un
cálculo independiente. `puede_comprar_alcohol` informa `SI` para mayores
de edad, `NO` para menores y `SIN DATOS` cuando falta la fecha. Un menor
puede tener `resultado = 'OK'` si su edad fue calculada correctamente.

**Captura del resultado:**

(image-2.png) --> en carpeta de imagenes-caso-de-prueba/ img-funciones

------------------------------------------------------------------------

## 5. `fn_CalcularSubtotal`

**Objetivo:** calcular el subtotal multiplicando la cantidad por el
precio unitario. No necesita consultar tablas.

**Código:**

``` sql
CREATE OR ALTER FUNCTION dbo.fn_CalcularSubtotal (
    @p_cantidad INT,
    @p_precio_unitario DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN @p_cantidad * @p_precio_unitario;
END;
GO
```

**Explicación:** recibe la cantidad y el precio unitario, realiza la
multiplicación y devuelve el importe.

### Prueba: cálculo del subtotal

``` sql
-- Pruebas de calculo de subtotal
SELECT dbo.fn_calcular_subtotal(2, 45000.00) AS total_1;
SELECT dbo.fn_calcular_subtotal(10, 1200.50) AS total_2;
SELECT dbo.fn_calcular_subtotal(6, 18500.75) AS total_3;
```


**Captura del resultado:**

(image-3.png) --> en carpeta de imagenes-caso-de-prueba/ img-funciones

------------------------------------------------------------------------

## 6. Prueba adicional: identificadores inexistentes

Comprueba cómo responden las funciones cuando reciben el ID `999`,
suponiendo que no exista en las tablas.

``` sql
SELECT
    dbo.fn_SaldoPendiente(999) AS saldo_inexistente,
    dbo.fn_CalcularDescuento(999) AS descuento_inexistente,
    dbo.fn_EdadCliente(999) AS edad_inexistente,
    CASE
        WHEN dbo.fn_SaldoPendiente(999) IS NULL
         AND dbo.fn_CalcularDescuento(999) = 0
         AND dbo.fn_EdadCliente(999) IS NULL
        THEN 'OK' ELSE 'ERROR'
    END AS resultado;
GO
```

**Resultado esperado:** saldo `NULL`, descuento `0` y edad `NULL`. Antes
de ejecutar, comprobar que el ID 999 no esté utilizado.

**Captura del resultado:**

(image-4.png) --> en carpeta de imagenes-caso-de-prueba/ img-funciones

------------------------------------------------------------------------

## 7. Resumen

  -----------------------------------------------------------------------
  Función                             Finalidad
  ----------------------------------- -----------------------------------
  `fn_SaldoPendiente`                 Calcula el saldo pendiente de una
                                      venta.

  `fn_CalcularDescuento`              Determina el descuento según las
                                      ventas acumuladas.

  `fn_EdadCliente`                    Calcula la edad en años cumplidos.

  `fn_CalcularSubtotal`               Multiplica cantidad por precio
                                      unitario.
  -----------------------------------------------------------------------

Las funciones permiten reutilizar cálculos y consultas dentro del
sistema VINOTECA. Las pruebas incluidas verifican sus resultados en
situaciones habituales y en algunos casos particulares.
