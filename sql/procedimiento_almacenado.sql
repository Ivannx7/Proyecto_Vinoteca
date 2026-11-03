-- =========================================================
-- 1. ELIMINACIÓN DE OBJETOS EXISTENTES (SI YA ESTÁN CREADOS)
-- =========================================================
IF OBJECT_ID('sp_registrar_venta', 'P') IS NOT NULL DROP PROCEDURE sp_registrar_venta;
IF OBJECT_ID('sp_registrar_pago', 'P') IS NOT NULL DROP PROCEDURE sp_registrar_pago;
IF OBJECT_ID('sp_actualizar_stock', 'P') IS NOT NULL DROP PROCEDURE sp_actualizar_stock;
IF OBJECT_ID('sp_actualizar_precio_vino', 'P') IS NOT NULL DROP PROCEDURE sp_actualizar_precio_vino;
IF OBJECT_ID('sp_eliminar_registro', 'P') IS NOT NULL DROP PROCEDURE sp_eliminar_registro;

IF OBJECT_ID('fn_calcular_subtotal', 'FN') IS NOT NULL DROP FUNCTION fn_calcular_subtotal;
IF OBJECT_ID('fn_calcular_precio_con_descuento', 'FN') IS NOT NULL DROP FUNCTION fn_calcular_precio_con_descuento;
GO

-- =========================================================
-- 2. FUNCIONES ALMACENADAS
-- =========================================================

---------------------------------------------------------
-- 1. fn_calcular_subtotal
--   Calcula el subtotal monetario de una línea de compra 
--   multiplicando la cantidad de unidades por el precio unitario.
--   Tablas afectadas: Ninguna (función de cálculo escalar puro).
--   Retorna: Un valor DECIMAL(12,2) con el monto total.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
CREATE FUNCTION fn_calcular_subtotal(
    @p_cantidad INT, 
    @p_precio_unitario DECIMAL(12,2)
) 
RETURNS DECIMAL(12,2)
WITH SCHEMABINDING
BEGIN
    RETURN @p_cantidad * @p_precio_unitario;
END;
GO

---------------------------------------------------------
-- 2. fn_calcular_precio_con_descuento
--   Calcula el precio final de un producto aplicando un 
--   porcentaje de descuento sobre su precio original.
--   Tablas afectadas: Ninguna (función de cálculo escalar puro).
--   Retorna: Un valor DECIMAL(12,2) con el precio rebajado.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
CREATE FUNCTION fn_calcular_precio_con_descuento(
    @p_precio_original DECIMAL(12,2),
    @p_porcentaje_descuento DECIMAL(5,2)
) 
RETURNS DECIMAL(12,2)
WITH SCHEMABINDING
BEGIN
    DECLARE @v_precio_final DECIMAL(12,2);
    
    -- Calcula el precio restando el porcentaje de descuento
    SET @v_precio_final = @p_precio_original - (@p_precio_original * (@p_porcentaje_descuento / 100.0));
    
    RETURN @v_precio_final;
END;
GO

-- =========================================================
-- 3. PROCEDIMIENTOS ALMACENADOS
-- =========================================================

---------------------------------------------------------
-- 1. sp_registrar_venta
--   Registra una nueva venta en el sistema junto con su detalle,
--   calculando el subtotal y generando los IDs correspondientes.
--   Tablas afectadas: venta, detalle_venta, vino (stock).
--   Los errores se informan con THROW.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
CREATE PROCEDURE sp_registrar_venta
    @p_id_cliente INT,
    @p_id_usuario INT,
    @p_id_vino INT,
    @p_cantidad INT,
    @p_precio_unitario_historico DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_id_venta INT;
    DECLARE @v_subtotal DECIMAL(12,2);

    SET @v_subtotal = @p_cantidad * @p_precio_unitario_historico;

    INSERT INTO venta (fecha_hora, monto_total, tipo_comprobante, id_cliente, id_usuario)
    VALUES (GETDATE(), @v_subtotal, 'Factura', @p_id_cliente, @p_id_usuario);

    SET @v_id_venta = SCOPE_IDENTITY();

    INSERT INTO detalle_venta (cantidad, precio_unitario_historico, porcentaje_descuento, id_vino, id_venta)
    VALUES (@p_cantidad, @p_precio_unitario_historico, 0, @p_id_vino, @v_id_venta);

    SELECT 'Venta registrada con éxito.' AS resultado, @v_id_venta AS id_venta_generada;
END;
GO

---------------------------------------------------------
-- 2. sp_registrar_pago
--   Registra un pago asociado a una venta existente en el sistema.
--   Tablas afectadas: venta_pago (validando la existencia en venta y metodo_pago).
--   Los errores se informan con THROW.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
CREATE PROCEDURE sp_registrar_pago
    @p_id_venta INT,
    @p_id_metodo_pago INT,
    @p_monto DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    -- Validar que la venta exista antes de registrar el pago
    IF EXISTS (SELECT 1 FROM venta WHERE id_venta = @p_id_venta) 
    BEGIN
        INSERT INTO venta_pago (fecha_hora, monto, id_venta, id_metodo_pago)
        VALUES (GETDATE(), @p_monto, @p_id_venta, @p_id_metodo_pago);
        
        SELECT 'Pago registrado con éxito.' AS resultado, SCOPE_IDENTITY() AS id_pago_generado;
    END
    ELSE
    BEGIN
        SELECT 'Error: La venta especificada no existe.' AS resultado;
    END
END;
GO

---------------------------------------------------------
-- 3. sp_actualizar_stock
--   Actualiza la cantidad de stock actual de un vino específico,
--   permitiendo sumar o restar según el signo del parámetro recibido.
--   Tablas afectadas: vino.
--   Los errores se informan con THROW.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
CREATE PROCEDURE sp_actualizar_stock
    @p_id_vino INT,
    @p_cantidad INT -- Puede ser positivo (suma) o negativo (resta)
AS
BEGIN
    SET NOCOUNT ON;
    -- Validar que la cantidad no sea cero
    IF @p_cantidad = 0 
    BEGIN
        SELECT 'Error: La cantidad no puede ser cero.' AS resultado;
    END
    ELSE
    BEGIN
        -- Actualiza sumando o restando según el signo de @p_cantidad
        UPDATE vino 
        SET stock_actual = stock_actual + @p_cantidad
        WHERE id_vino = @p_id_vino;
        
        SELECT 'Stock actualizado correctamente.' AS resultado, 
               stock_actual AS nuevo_stock_actual 
        FROM vino 
        WHERE id_vino = @p_id_vino;
    END
END;
GO

---------------------------------------------------------
-- 4. sp_actualizar_precio_vino
--   Registra el cambio de precio de un vino en el historial de precios
--   y actualiza su valor vigente en la tabla principal de vinos.
--   Tablas afectadas: historial_precio, vino.
--   Los errores se informan con THROW.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
CREATE PROCEDURE sp_actualizar_precio_vino
    @p_id_vino INT,
    @p_nuevo_precio DECIMAL(10,2),
    @p_id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO historial_precio (fecha_vigencia, precio_nuevo, precio_anterior, id_usuario, id_vino, id_detalle_venta)
    SELECT GETDATE(), @p_nuevo_precio, precio_venta, @p_id_usuario, id_vino, NULL
    FROM vino
    WHERE id_vino = @p_id_vino;

    UPDATE vino
    SET precio_venta = @p_nuevo_precio
    WHERE id_vino = @p_id_vino;

    SELECT 'Precio actualizado correctamente y registrado en el historial.' AS resultado;
END;
GO

---------------------------------------------------------
-- 5. sp_eliminar_registro
--   Borra un registro (por su ID) de una tabla del proyecto.
--   Tablas permitidas: cepa, categoria, pais, region, bodega, rol,
--                       metodo_pago, cliente, usuario, vino
--   Tablas NO permitidas (transaccionales / históricas): venta,
--   detalle_venta, venta_pago, historial_precio, vino_cepa.
--   Los errores se informan con THROW.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
CREATE PROCEDURE sp_eliminar_registro
    @p_tabla VARCHAR(128),
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_tabla VARCHAR(128);
    DECLARE @v_pk VARCHAR(128);
    DECLARE @v_sql NVARCHAR(MAX);
    DECLARE @v_temp_existe INT;

    -- 1. Validar tabla
    SET @v_tabla = LOWER(LTRIM(RTRIM(@p_tabla)));

    IF @v_tabla IN ('venta', 'detalle_venta', 'venta_pago', 'historial_precio', 'vino_cepa') 
    BEGIN
        THROW 50000, 'No se permite borrar registros de tablas transaccionales o históricas.', 1;
        RETURN;
    END;

    IF @v_tabla NOT IN ('cepa', 'categoria', 'pais', 'region', 'bodega', 'rol',
                        'metodo_pago', 'cliente', 'usuario', 'vino') 
    BEGIN
        THROW 50001, 'La tabla indicada no existe o no está habilitada para eliminar registros.', 1;
        RETURN;
    END;

    -- 2. Validar ID
    IF @p_id IS NULL OR @p_id <= 0 
    BEGIN
        THROW 50002, 'El ID debe ser un número mayor a cero.', 1;
        RETURN;
    END;

    -- 3. Validar que el registro exista (usando SQL Dinámico seguro en SQL Server)
    SET @v_pk = 'id_' + @v_tabla;
    
    SET @v_sql = N'SELECT @v_temp_existe_out = COUNT(*) FROM ' + QUOTENAME(@v_tabla) + ' WHERE ' + QUOTENAME(@v_pk) + ' = @p_id_val';
    
    EXEC sp_executesql @v_sql, 
         N'@p_id_val INT, @v_temp_existe_out INT OUTPUT', 
         @p_id_val = @p_id, 
         @v_temp_existe_out = @v_temp_existe OUTPUT;

    IF @v_temp_existe = 0 
    BEGIN
        THROW 50003, 'No existe un registro con ese ID en la tabla indicada.', 1;
        RETURN;
    END;

    -- 4. Caso especial: un vino con ventas o historial de precios no se puede borrar
    IF @v_tabla = 'vino' 
    BEGIN
        IF EXISTS (SELECT 1 FROM detalle_venta WHERE id_vino = @p_id)
        OR EXISTS (SELECT 1 FROM historial_precio WHERE id_vino = @p_id) 
        BEGIN
            THROW 50004, 'No se puede eliminar el vino: tiene ventas o historial de precios. Use la baja lógica (estado).', 1;
            RETURN;
        END;

        -- Sus cepas son datos dependientes y se eliminan junto con el vino
        DELETE FROM vino_cepa WHERE id_vino = @p_id;
    END;

    -- Bloque Try-Catch para capturar violaciones de restricciones de clave foránea (equivalente al error 1451 de MySQL)
    BEGIN TRY
        SET @v_sql = N'DELETE FROM ' + QUOTENAME(@v_tabla) + ' WHERE ' + QUOTENAME(@v_pk) + ' = @p_id_val';
        EXEC sp_executesql @v_sql, N'@p_id_val INT', @p_id_val = @p_id;

        -- Retornar resultado exitoso
        SELECT 'Registro eliminado con éxito.' AS resultado,
               @v_tabla AS tabla,
               @p_id AS id_eliminado;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 547 -- Violación de foreign key en SQL Server
        BEGIN
            THROW 50005, 'No se puede eliminar: el registro está referenciado por otros datos. Considere una baja lógica (estado).', 1;
        END
        ELSE
        BEGIN
            THROW;
        END
    END CATCH;
END;
GO

-- =====================================================================
-- 4. SCRIPT DE PRUEBAS Y LLAMADAS (DEMOSTRACIÓN)
-- =====================================================================

-- Venta 1: Vino ID 3 (Colomé Estate Malbec - Precio: $60.000 x 2 = $120.000)
EXEC sp_registrar_venta @p_id_cliente = 3, @p_id_usuario = 1, @p_id_vino = 3, @p_cantidad = 2, @p_precio_unitario_historico = 60000.00;
EXEC sp_registrar_pago @p_id_venta = 1, @p_id_metodo_pago = 1, @p_monto = 120000.00;
EXEC sp_actualizar_stock @p_id_vino = 3, @p_cantidad = 2;
EXEC sp_actualizar_precio_vino @p_id_vino = 3, @p_nuevo_precio = 40000.00, @p_id_usuario = 1;

-- Venta 2: Vino ID 4 (Concha y Toro Cabernet - Precio: $22.000 x 1 = $22.000)
EXEC sp_registrar_venta @p_id_cliente = 1, @p_id_usuario = 1, @p_id_vino = 4, @p_cantidad = 1, @p_precio_unitario_historico = 22000.00;
EXEC sp_registrar_pago @p_id_venta = 2, @p_id_metodo_pago = 3, @p_monto = 22000.00;
EXEC sp_actualizar_stock @p_id_vino = 4, @p_cantidad = 1;
EXEC sp_actualizar_precio_vino @p_id_vino = 4, @p_nuevo_precio = 18000.00, @p_id_usuario = 1;

-- Venta 3: Vino ID 7 (Château Margaux - Precio: $850.000 x 1 = $850.000)
EXEC sp_registrar_venta @p_id_cliente = 7, @p_id_usuario = 1, @p_id_vino = 7, @p_cantidad = 1, @p_precio_unitario_historico = 850000.00;
EXEC sp_registrar_pago @p_id_venta = 3, @p_id_metodo_pago = 1, @p_monto = 850000.00;
EXEC sp_actualizar_stock @p_id_vino = 7, @p_cantidad = 1;

-- Venta 4: Vino ID 8 (Antinori Toscana Syrah - Precio: $55.000 x 3 = $165.000)
EXEC sp_registrar_venta @p_id_cliente = 8, @p_id_usuario = 1, @p_id_vino = 8, @p_cantidad = 3, @p_precio_unitario_historico = 55000.00;
EXEC sp_registrar_pago @p_id_venta = 4, @p_id_metodo_pago = 3, @p_monto = 165000.00;
EXEC sp_actualizar_stock @p_id_vino = 8, @p_cantidad = 3;
EXEC sp_actualizar_precio_vino @p_id_vino = 8, @p_nuevo_precio = 50000.00, @p_id_usuario = 1;

-- Prueba de eliminación de registro permitido
EXEC sp_eliminar_registro @p_tabla = 'categoria', @p_id = 5;

-- Pruebas de llamadas a las funciones almacenadas
SELECT dbo.fn_calcular_subtotal(2, 45000.00) AS total_1;
SELECT dbo.fn_calcular_subtotal(10, 1200.50) AS total_2;
SELECT dbo.fn_calcular_subtotal(6, 18500.75) AS total_3;

SELECT dbo.fn_calcular_precio_con_descuento(20000.00, 10.00) AS precio_con_10_off;
SELECT dbo.fn_calcular_precio_con_descuento(50000.00, 25.00) AS precio_con_25_off;
SELECT dbo.fn_calcular_precio_con_descuento(75000.00, 20.00) AS precio_con_20_off;
GO
