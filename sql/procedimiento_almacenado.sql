-- Asegúrate de restablecer el delimitador por defecto si estabas en medio de otro bloque
DELIMITER ;
DROP PROCEDURE IF EXISTS sp_registrar_venta;
DROP PROCEDURE IF EXISTS sp_registrar_pago;
DROP PROCEDURE IF EXISTS sp_actualizar_stock;
DROP PROCEDURE IF EXISTS sp_actualizar_precio_vino;
DROP PROCEDURE IF EXISTS sp_eliminar_registro;

---------------------------------------------------------
-- 1. sp_registrar_venta
--   Registra una nueva venta en el sistema junto con su detalle,
--   calculando el subtotal y generando los IDs correspondientes.
--   Tablas afectadas: venta, detalle_venta, vino (stock).
--   Los errores se informan con SIGNAL SQLSTATE.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_registrar_venta(
    IN p_id_cliente INT,
    IN p_id_usuario INT,
    IN p_id_vino INT,
    IN p_cantidad INT,
    IN p_precio_unitario_historico DECIMAL(12,2)
)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE v_subtotal DECIMAL(12,2);

    SET v_subtotal = p_cantidad * p_precio_unitario_historico;

    INSERT INTO venta (fecha_hora, monto_total, tipo_comprobante, id_cliente, id_usuario)
    VALUES (NOW(), v_subtotal, 'Factura', p_id_cliente, p_id_usuario);

    SET v_id_venta = LAST_INSERT_ID();

    INSERT INTO detalle_venta (cantidad, precio_unitario_historico, porcentaje_descuento, id_vino, id_venta)
    VALUES (p_cantidad, p_precio_unitario_historico, 0, p_id_vino, v_id_venta);

    SELECT 'Venta registrada con éxito.' AS resultado, v_id_venta AS id_venta_generada;
END //

DELIMITER ;

---------------------------------------------------------
-- 2. sp_registrar_pago
--   Registra un pago asociado a una venta existente en el sistema.
--   Tablas afectadas: venta_pago (validando la existencia en venta y metodo_pago).
--   Los errores se informan con SIGNAL SQLSTATE.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_registrar_pago(
    IN p_id_venta INT,
    IN p_id_metodo_pago INT,
    IN p_monto DECIMAL(12,2)
)
BEGIN
    -- Validar que la venta exista antes de registrar el pago
    IF EXISTS (SELECT 1 FROM venta WHERE id_venta = p_id_venta) THEN
        INSERT INTO venta_pago (fecha_hora, monto, id_venta, id_metodo_pago)
        VALUES (NOW(), p_monto, p_id_venta, p_id_metodo_pago);
        
        SELECT 'Pago registrado con éxito.' AS resultado, LAST_INSERT_ID() AS id_pago_generado;
    ELSE
        SELECT 'Error: La venta especificada no existe.' AS resultado;
    END IF;
END //

DELIMITER ;

---------------------------------------------------------
-- 3. sp_actualizar_stock
--   Actualiza la cantidad de stock actual de un vino específico,
--   permitiendo sumar o restar según el signo del parámetro recibido.
--   Tablas afectadas: vino.
--   Los errores se informan con SIGNAL SQLSTATE.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_actualizar_stock(
    IN p_id_vino INT,
    IN p_cantidad INT -- Puede ser positivo (suma) o negativo (resta)
)
BEGIN
    -- Validar que la cantidad no sea cero
    IF p_cantidad = 0 THEN
        SELECT 'Error: La cantidad no puede ser cero.' AS resultado;
    ELSE
        -- Actualiza sumando o restando según el signo de p_cantidad
        UPDATE vino 
        SET stock_actual = stock_actual + p_cantidad
        WHERE id_vino = p_id_vino;
        
        -- Validar opcionalmente que el stock no quede en negativo (opcional)
        -- (Si manejas stock negativo, puedes omitir esta validación)
        
        SELECT 'Stock actualizado correctamente.' AS resultado, 
               stock_actual AS nuevo_stock_actual 
        FROM vino 
        WHERE id_vino = p_id_vino;
    END IF;
END //

DELIMITER ;

---------------------------------------------------------
-- 4. sp_actualizar_precio_vino
--   Registra el cambio de precio de un vino en el historial de precios
--   y actualiza su valor vigente en la tabla principal de vinos.
--   Tablas afectadas: historial_precio, vino.
--   Los errores se informan con SIGNAL SQLSTATE.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_actualizar_precio_vino(
    IN p_id_vino INT,
    IN p_nuevo_precio DECIMAL(10,2),
    IN p_id_usuario INT
)
BEGIN
    INSERT INTO historial_precio (fecha_vigencia, precio_nuevo, precio_anterior, id_usuario, id_vino, id_detalle_venta)
    SELECT NOW(), p_nuevo_precio, precio_venta, p_id_usuario, id_vino, NULL
    FROM vino
    WHERE id_vino = p_id_vino;

    UPDATE vino
    SET precio_venta = p_nuevo_precio
    WHERE id_vino = p_id_vino;

    SELECT 'Precio actualizado correctamente y registrado en el historial.' AS resultado;
END //

DELIMITER ;

---------------------------------------------------------
-- 5. sp_eliminar_registro
--   Borra un registro (por su ID) de una tabla del proyecto.
--   Tablas permitidas: cepa, categoria, pais, region, bodega, rol,
--                      metodo_pago, cliente, usuario, vino
--   Tablas NO permitidas (transaccionales / históricas): venta,
--   detalle_venta, venta_pago, historial_precio, vino_cepa.
--   Los errores se informan con THROW.
--   (El manejo de transacciones lo controla el módulo correspondiente.)
---------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_eliminar_registro(
    IN p_tabla VARCHAR(128),
    IN p_id INT
)
BEGIN
    DECLARE v_tabla VARCHAR(128);
    DECLARE v_pk VARCHAR(128);
    
    -- Manejador de excepciones para errores de clave foránea (Error 1451)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 
            @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        
        IF @errno = 1451 THEN
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'No se puede eliminar: el registro está referenciado por otros datos. Considere una baja lógica (estado).';
        ELSE 
            RESIGNAL;
        END IF;
    END;

    -- 1. Validar tabla
    SET v_tabla = LOWER(TRIM(p_tabla));

    IF v_tabla IN ('venta', 'detalle_venta', 'venta_pago', 'historial_precio', 'vino_cepa') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se permite borrar registros de tablas transaccionales o históricas.';
    END IF;

    IF v_tabla NOT IN ('cepa', 'categoria', 'pais', 'region', 'bodega', 'rol',
                        'metodo_pago', 'cliente', 'usuario', 'vino') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La tabla indicada no existe o no está habilitada para eliminar registros.';
    END IF;

    -- 2. Validar ID
    IF p_id IS NULL OR p_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El ID debe ser un número mayor a cero.';
    END IF;

    -- 3. Validar que el registro exista
    SET v_pk = CONCAT('id_', v_tabla);
    
    SET @v_sql = CONCAT('SELECT COUNT(*) INTO @v_temp_existe FROM `', v_tabla, '` WHERE `', v_pk, '` = ?');
    PREPARE stmt FROM @v_sql;
    SET @p_id_val = p_id;
    EXECUTE stmt USING @p_id_val;
    DEALLOCATE PREPARE stmt;

    IF @v_temp_existe = 0 THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'No existe un registro con ese ID en la tabla indicada.';
    END IF;

    -- 4. Caso especial: un vino con ventas o historial de precios no se puede borrar
    IF v_tabla = 'vino' THEN
        IF EXISTS (SELECT 1 FROM detalle_venta WHERE id_vino = p_id)
        OR EXISTS (SELECT 1 FROM historial_precio WHERE id_vino = p_id) THEN
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'No se puede eliminar el vino: tiene ventas o historial de precios. Use la baja lógica (estado).';
        END IF;

        -- Sus cepas son datos dependientes y se eliminan junto con el vino
        DELETE FROM vino_cepa WHERE id_vino = p_id;
    END IF;

    -- 5. Eliminar el registro
    SET @v_sql = CONCAT('DELETE FROM `', v_tabla, '` WHERE `', v_pk, '` = ?');
    PREPARE stmt FROM @v_sql;
    SET @p_id_val = p_id;
    EXECUTE stmt USING @p_id_val;
    DEALLOCATE PREPARE stmt;

    -- Retornar resultado exitoso
    SELECT 'Registro eliminado con éxito.' AS resultado,
           v_tabla AS tabla,
           p_id AS id_eliminado;
END //

DELIMITER ;

-----------------------------------------------------
-- INVOCACIONES
-----------------------------------------------------
    
-- Venta 1: Vino ID 3 (Colomé Estate Malbec - Precio: $60.000 x 2 = $120.000)
EXEC sp_registrar_venta 3, 1, 3, 2, 60000.00;
EXEC sp_registrar_pago 1, 1, 120000.00;
EXEC sp_actualizar_stock 3, -2; -- Negativo porque es una venta (resta stock)
EXEC sp_actualizar_precio_vino 3, 40000.00, 1;

-- Venta 2: Vino ID 4 (Concha y Toro Cabernet - Precio: $22.000 x 1 = $22.000)
EXEC sp_registrar_venta 1, 1, 4, 1, 22000.00;
EXEC sp_registrar_pago 2, 3, 22000.00;
EXEC sp_actualizar_stock 4, -1;
EXEC sp_actualizar_precio_vino 4, 18000.00, 1;

-- Venta 3: Vino ID 7 (Château Margaux - Precio: $850.000 x 1 = $850.000)
EXEC sp_registrar_venta 7, 1, 7, 1, 850000.00;
EXEC sp_registrar_pago 3, 1, 850000.00;
EXEC sp_actualizar_stock 7, -1;

-- Venta 4: Vino ID 8 (Antinori Toscana Syrah - Precio: $55.000 x 3 = $165.000)
EXEC sp_registrar_venta 8, 1, 8, 3, 55000.00;
EXEC sp_registrar_pago 4, 3, 165000.00;
EXEC sp_actualizar_stock 8, -3;
EXEC sp_actualizar_precio_vino 8, 50000.00, 1;

-- Prueba de eliminación (Intentará borrar la categoría con ID 5)
EXEC sp_eliminar_registro 'categoria', 5;
