USE VINOTECA;
GO

-- DML

-- 1. CEPA
-- [CORREGIDO: columna "nombre" (no "nombre_cepa")]
INSERT INTO cepa (nombre)
VALUES
('Malbec'),                  -- 1
('Cabernet Sauvignon'),      -- 2
('Merlot'),                  -- 3
('Syrah'),                   -- 4
('Bonarda'),                 -- 5
('Tempranillo'),             -- 6
('Torrontés'),               -- 7
('Chardonnay');              -- 8

-- 2. CATEGORIA
INSERT INTO categoria (nombre_categoria, descripcion)
VALUES
('Tinto', 'Vinos elaborados con uvas tintas'),                          -- 1
('Blanco', 'Vinos elaborados con uvas blancas'),                        -- 2
('Rosado', 'Vinos de maceración corta con uvas tintas'),                -- 3
('Espumante', 'Vinos con burbujas, método charmat o champenoise'),      -- 4
('Vino de Postre', 'Vinos dulces o de cosecha tardía'),                 -- 5
('Reserva', 'Vinos con crianza en barrica y botella'),                  -- 6
('Gran Reserva', 'Vinos de larga crianza y guarda'),                    -- 7
('Orgánico', 'Vinos de viñedos con certificación orgánica');            -- 8

-- 3. PAIS
-- [CORREGIDO: columna "nombre" (no "nombre_pais")]
INSERT INTO pais (nombre)
VALUES
('Argentina'),        -- 1
('Chile'),            -- 2
('Uruguay'),          -- 3
('España'),           -- 4
('Francia'),          -- 5
('Italia'),           -- 6
('Portugal'),         -- 7
('Estados Unidos');   -- 8

-- 4. ROL
-- [CORREGIDO: columna "nombre" (no "nombre_rol"); se agrega "fecha_creacion",
--  obligatoria en la tabla y faltante en la versión subida]
INSERT INTO rol (nombre, descripcion, fecha_creacion, estado)
VALUES
('Administrador', 'Acceso total al sistema', '2025-01-10', 1),                          -- 1
('Gerente', 'Autoriza descuentos y anulaciones', '2025-01-10', 1),                      -- 2
('Vendedor', 'Registra ventas y atiende clientes', '2025-01-10', 1),                    -- 3
('Cajero', 'Registra pagos y emite comprobantes', '2025-01-10', 1),                     -- 4
('Sommelier', 'Asesora en la selección de vinos', '2025-02-01', 1),                     -- 5
('Encargado de depósito', 'Gestiona stock y recepción de mercadería', '2025-02-01', 1), -- 6
('Auditor', 'Consulta de reportes solo lectura', '2025-03-15', 1),                      -- 7
('Soporte', 'Mantenimiento técnico del sistema', '2025-03-15', 1);                      -- 8

-- 5. CLIENTE
-- [CORREGIDO: columna "correo_electronico" (no "email")]
INSERT INTO cliente (nombre, apellido, dni, telefono, correo_electronico, fecha_nacimiento, es_consumidor_final)
VALUES
('Ivan', 'Benitez', '46544211', '3794-123455', 'ivan.benitez@mail.com','2004-03-15', 1),          -- 1
('Juan', 'Pérez', '30123456', '3794-123456', 'juan.perez@mail.com', '1984-07-22', 0),              -- 2
('María', 'González', '28456789', '3794-234567', 'maria.gonzalez@mail.com','1981-11-05', 0),       -- 3
('Carlos', 'Rodríguez', '33789012', '3794-345678', 'carlos.rodriguez@mail.com', '1988-02-18', 1),  -- 4
('Lucía', 'Fernández', '35111222', '3777-456789', 'lucia.fernandez@mail.com','1991-09-30', 0),     -- 5
('Martín', 'López', '29333444', '3794-567890', 'martin.lopez@mail.com', '1982-12-10', 1),          -- 6
('Vinoteca', 'Del Centro SRL', '41234567', '3794-678901', 'compras@vinotecadelcentro.com', '1990-01-01', 0), -- 7
('Sofía', 'Martínez', '38555666', '3794-789012', 'sofia.martinez@mail.com', '1993-06-27', 1);      -- 8

-- 6. METODO_PAGO
INSERT INTO metodo_pago (nombre_metodo, estado)
VALUES
('Efectivo', 1),               -- 1
('Tarjeta de Débito', 1),      -- 2
('Tarjeta de Crédito', 1),     -- 3
('Transferencia Bancaria', 1), -- 4
('Mercado Pago', 1),           -- 5
('Código QR', 1),              -- 6
('Cheque', 0),                 -- 7 Inactivo
('Cuenta Corriente', 1);       -- 8

-- 7. REGION (FK: pais)
-- [CORREGIDO: columna "id_pais" (no "pais_id")]
INSERT INTO region (nombre, id_pais)
VALUES
('Valle de Uco', 1),           -- 1 Argentina
('Luján de Cuyo', 1),          -- 2 Argentina
('Valles Calchaquíes', 1),     -- 3 Argentina
('Valle del Maipo', 2),        -- 4 Chile
('Canelones', 3),              -- 5 Uruguay
('Rioja', 4),                  -- 6 España
('Burdeos', 5),                -- 7 Francia
('Toscana', 6);                -- 8 Italia

-- 8. USUARIO (FK: rol)
-- [CORREGIDO: columna "id_rol" (no "rol_id")]
INSERT INTO usuario (nombre, apellido, correo_electronico, contrasena, estado, fecha_registro, ultimo_inicio_sesion, id_rol)
VALUES
('Admin', 'Sistema', 'admin@vinoteca.com', 'ib918377', 'Activo', '2025-01-10 09:00:00', '2026-09-29 08:30:00', 1),           -- 1
('Laura', 'Benítez', 'laura.benitez@vinoteca.com', '13131239', 'Activo', '2025-01-12 10:15:00', '2026-09-29 09:10:00', 2),   -- 2
('Diego', 'Acosta', 'diego.acosta@vinoteca.com', '99012931', 'Activo', '2025-01-15 11:00:00', '2026-09-28 18:45:00', 3),     -- 3
('Valeria', 'Romero', 'valeria.romero@vinoteca.com', '13910348', 'Activo', '2025-01-15 11:30:00', '2026-09-28 19:00:00', 4), -- 4
('Pablo', 'Sosa', 'pablo.sosa@vinoteca.com', '77819211', 'Activo', '2025-02-01 09:30:00', '2026-09-27 17:20:00', 5),         -- 5
('Andrea', 'Molina', 'andrea.molina@vinoteca.com', '31344511', 'Activo', '2025-02-03 08:45:00', '2026-09-26 12:00:00', 6),   -- 6
('Ricardo', 'Vega', 'ricardo.vega@vinoteca.com', '19038174', 'Inactivo', '2025-03-15 14:00:00', NULL, 7),                   -- 7
('Natalia', 'Duarte', 'natalia.duarte@vinoteca.com', 'sj910381', 'Activo', '2025-03-16 10:00:00', '2026-09-25 16:30:00', 8); -- 8

-- ======================= TABLAS NUEVAS (faltaban) =======================

-- 9. BODEGA (FK: region)
INSERT INTO bodega (nombre, descripcion, id_region) VALUES
('Catena Zapata', 'Bodega de altura en el Valle de Uco', 1),               -- 1
('Luigi Bosca', 'Bodega histórica de Luján de Cuyo', 2),                   -- 2
('Colomé', 'Viñedos de altura extrema en los Calchaquíes', 3),             -- 3
('Concha y Toro', 'Una de las bodegas más grandes de Sudamérica', 4),      -- 4
('Bodega Bouza', 'Bodega boutique uruguaya de Canelones', 5),              -- 5
('Marqués de Riscal', 'Bodega tradicional de La Rioja española', 6),      -- 6
('Château Margaux', 'Grand Cru Classé de Burdeos', 7),                     -- 7
('Marchesi Antinori', 'Bodega histórica de la Toscana', 8);                -- 8

-- 10. VINO (FK: categoria, bodega)
INSERT INTO vino (nombre, cosecha, graduacion_alcoholica, descripcion, precio_venta, stock_actual, stock_minimo, estado, id_categoria, id_bodega)
VALUES
('Catena Zapata Malbec Argentino', 2021, 13.50, 'Tinto de guarda de altura', 45000.00, 50, 10, 'Activo', 1, 1),       -- 1
('Luigi Bosca Chardonnay', 2022, 12.80, 'Blanco fresco de Luján de Cuyo', 18000.00, 80, 15, 'Activo', 2, 2),          -- 2
('Colomé Estate Malbec', 2020, 14.00, 'Tinto de altura extrema, viñedos centenarios', 60000.00, 30, 5, 'Activo', 1, 3), -- 3
('Concha y Toro Cabernet Sauvignon', 2021, 13.80, 'Tinto chileno del Valle del Maipo', 22000.00, 90, 15, 'Activo', 1, 4), -- 4
('Bouza Merlot', 2020, 13.00, 'Tinto uruguayo de Canelones', 25000.00, 40, 8, 'Activo', 1, 5),                        -- 5
('Marqués de Riscal Reserva', 2019, 14.50, 'Tinto español D.O.Ca. Rioja', 35000.00, 40, 8, 'Activo', 6, 6),           -- 6
('Château Margaux Grand Vin', 2015, 13.80, 'Gran vino de Burdeos, Premier Grand Cru Classé', 850000.00, 5, 2, 'Activo', 7, 7), -- 7
('Antinori Toscana Syrah', 2020, 13.50, 'Tinto italiano de la Toscana', 55000.00, 25, 5, 'Activo', 6, 8);             -- 8

-- 11. VINO_CEPA (relación N:M entre vino y cepa)
INSERT INTO vino_cepa (id_vino, id_cepa) VALUES
(1, 1),  -- Catena Zapata Malbec Argentino - Malbec
(2, 8),  -- Luigi Bosca Chardonnay - Chardonnay
(3, 1),  -- Colomé Estate Malbec - Malbec
(4, 2),  -- Concha y Toro Cabernet Sauvignon - Cabernet Sauvignon
(5, 3),  -- Bouza Merlot - Merlot
(6, 6),  -- Marqués de Riscal Reserva - Tempranillo
(7, 2),  -- Château Margaux Grand Vin - Cabernet Sauvignon
(8, 4);  -- Antinori Toscana Syrah - Syrah

-- 12. VENTA (FK: cliente, usuario)
INSERT INTO venta (fecha_hora, monto_total, tipo_comprobante, id_cliente, id_usuario) VALUES
('2026-02-03 10:15:00', 90000.00,  'Factura B', 2, 3),  -- 1
('2026-02-05 16:40:00', 97200.00,  'Factura B', 3, 4),  -- 2
('2026-02-10 12:00:00', 60000.00,  'Factura A', 7, 3),  -- 3
('2026-02-14 18:20:00', 237600.00, 'Ticket',    1, 4),  -- 4
('2026-03-01 11:05:00', 75000.00,  'Ticket',    6, 3),  -- 5
('2026-03-04 15:30:00', 140000.00, 'Factura B', 5, 4),  -- 6
('2026-03-09 13:45:00', 850000.00, 'Factura A', 7, 2),  -- 7
('2026-03-15 17:00:00', 110000.00, 'Factura B', 8, 3);  -- 8

-- 13. DETALLE_VENTA (FK: venta, vino)
-- Filas 2 y 4 llevan descuento por caja cerrada (RN-10: cantidad múltiplo de 6)
INSERT INTO detalle_venta (cantidad, precio_unitario_historico, porcentaje_descuento, id_vino, id_venta) VALUES
(2,  45000.00,  0.00,  1, 1),   -- 1
(6,  18000.00,  10.00, 2, 2),   -- 2
(1,  60000.00,  0.00,  3, 3),   -- 3
(12, 22000.00,  10.00, 4, 4),   -- 4
(3,  25000.00,  0.00,  5, 5),   -- 5
(4,  35000.00,  0.00,  6, 6),   -- 6
(1,  850000.00, 0.00,  7, 7),   -- 7
(2,  55000.00,  0.00,  8, 8);   -- 8

-- 14. HISTORIAL_PRECIO (FK: usuario, vino; id_detalle_venta queda NULL: son
--     actualizaciones de catálogo, no ligadas a una venta puntual)
INSERT INTO historial_precio (fecha_vigencia, precio_nuevo, precio_anterior, id_usuario, id_vino, id_detalle_venta) VALUES
('2026-01-01 09:00:00', 45000.00,  40000.00,  1, 1, NULL),  -- 1
('2026-01-05 09:00:00', 18000.00,  16000.00,  2, 2, NULL),  -- 2
('2026-01-10 09:00:00', 60000.00,  55000.00,  1, 3, NULL),  -- 3
('2026-01-15 09:00:00', 22000.00,  20000.00,  2, 4, NULL),  -- 4
('2026-01-20 09:00:00', 25000.00,  23000.00,  1, 5, NULL),  -- 5
('2026-01-25 09:00:00', 35000.00,  32000.00,  2, 6, NULL),  -- 6
('2026-02-01 09:00:00', 850000.00, 800000.00, 1, 7, NULL),  -- 7
('2026-02-01 09:00:00', 55000.00,  50000.00,  2, 8, NULL);  -- 8

-- 15. VENTA_PAGO (FK: venta, metodo_pago) - un pago por venta, por el monto total
INSERT INTO venta_pago (fecha_hora, monto, id_venta, id_metodo_pago) VALUES
('2026-02-03 10:15:00', 90000.00,  1, 1),  -- Efectivo
('2026-02-05 16:40:00', 97200.00,  2, 3),  -- Tarjeta de Crédito
('2026-02-10 12:00:00', 60000.00,  3, 4),  -- Transferencia Bancaria
('2026-02-14 18:20:00', 237600.00, 4, 2),  -- Tarjeta de Débito
('2026-03-01 11:05:00', 75000.00,  5, 1),  -- Efectivo
('2026-03-04 15:30:00', 140000.00, 6, 5),  -- Mercado Pago
('2026-03-09 13:45:00', 850000.00, 7, 8),  -- Cuenta Corriente
('2026-03-15 17:00:00', 110000.00, 8, 6);  -- Código QR
