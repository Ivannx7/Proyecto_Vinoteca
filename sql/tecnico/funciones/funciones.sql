USE VINOTECA;
GO
 
/* =====================================================================
   FUNCIONES
   ===================================================================== */
 
---------------------------------------------------------
-- 1. fn_SaldoPendiente
-- Calcula cuánto dinero falta pagar de una venta.
-- Resta el total de pagos registrados al monto total.
-- Si no existen pagos, ISNULL reemplaza NULL por 0.
-- Si la venta no existe, devuelve NULL.
---------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_SaldoPendiente (@p_id_venta INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @v_saldo DECIMAL(12,2);
 
    SELECT @v_saldo = v.monto_total
                      - ISNULL((SELECT SUM(vp.monto)
                                FROM venta_pago vp
                                WHERE vp.id_venta = v.id_venta), 0)
    FROM venta v
    WHERE v.id_venta = @p_id_venta;
 
    RETURN @v_saldo;
END;
GO
 
---------------------------------------------------------
-- 2. fn_CalcularDescuento
--    Descuento por compras acumuladas del cliente:
--      > $600.000 acumulados -> 10 %
--      > $300.000 acumulados ->  5 %
--      caso contrario        ->  0 %
---------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_CalcularDescuento (@p_id_cliente INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @v_acumulado DECIMAL(14,2);
 
    SELECT @v_acumulado = ISNULL(SUM(monto_total), 0)
    FROM venta
    WHERE id_cliente = @p_id_cliente;
 
    RETURN CASE
               WHEN @v_acumulado > 600000 THEN 10.00
               WHEN @v_acumulado > 300000 THEN  5.00
               ELSE 0.00
           END;
END;
GO
 
---------------------------------------------------------
-- 3. fn_EdadCliente
--    Edad exacta del cliente (años cumplidos).
--    Sirve para validar mayoría de edad en la venta de alcohol.
--    Devuelve NULL si el cliente no existe o no tiene fecha de nacimiento.
---------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_EdadCliente (@p_id_cliente INT)
RETURNS INT
AS
BEGIN
    DECLARE @v_nacimiento DATE;
    DECLARE @v_hoy DATE = CAST(GETDATE() AS DATE);
 
    SELECT @v_nacimiento = fecha_nacimiento
    FROM cliente
    WHERE id_cliente = @p_id_cliente;
 
    IF @v_nacimiento IS NULL
        RETURN NULL;
 
    -- DATEDIFF(YEAR) solo cuenta cambios de año; se resta 1 si aún no cumplió este año
    RETURN DATEDIFF(YEAR, @v_nacimiento, @v_hoy)
           - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @v_nacimiento, @v_hoy), @v_nacimiento) > @v_hoy
                  THEN 1 ELSE 0 END;
END;
GO

-- 4. fn_CalcularSubtotal
-- Calcula el subtotal de un producto multiplicando
-- la cantidad comprada por su precio unitario.
-- No necesita consultar tablas porque recibe ambos valores
-- directamente mediante parámetros.
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