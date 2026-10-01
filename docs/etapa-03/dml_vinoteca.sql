USE VINOTECA;
GO

-- DML

-- 1. CEPA
INSERT INTO cepa (nombre_cepa)
VALUES
('Malbec'),
('Cabernet Sauvignon'),
('Merlot'),
('Syrah'),
('Bonarda'),
('Tempranillo'),
('Torrontés'),
('Chardonnay');

-- 2. CATEGORIA
INSERT INTO categoria (nombre_categoria, descripcion) 
VALUES
('Tinto', 'Vinos elaborados con uvas tintas'),
('Blanco', 'Vinos elaborados con uvas blancas'),
('Rosado', 'Vinos de maceración corta con uvas tintas'),
('Espumante', 'Vinos con burbujas, método charmat o champenoise'),
('Vino de Postre', 'Vinos dulces o de cosecha tardía'),
('Reserva', 'Vinos con crianza en barrica y botella'),
('Gran Reserva', 'Vinos de larga crianza y guarda'),
('Orgánico', 'Vinos de viñedos con certificación orgánica');

-- 3. PAIS
INSERT INTO pais (nombre_pais) 
VALUES
('Argentina'),        -- 1
('Chile'),            -- 2
('Uruguay'),          -- 3
('España'),           -- 4
('Francia'),          -- 5
('Italia'),           -- 6
('Portugal'),         -- 7
('Estados Unidos');   -- 8

-- 4. ROL (estado BIT: 1 = activo)
INSERT INTO rol (nombre_rol, descripcion, estado) 
VALUES
('Administrador', 'Acceso total al sistema', 1),                        -- 1
('Gerente', 'Autoriza descuentos y anulaciones', 1),                    -- 2
('Vendedor', 'Registra ventas y atiende clientes', 1),                  -- 3
('Cajero', 'Registra pagos y emite comprobantes', 1),                   -- 4
('Sommelier', 'Asesora en la selección de vinos', 1),                   -- 5
('Encargado de depósito', 'Gestiona stock y recepción de mercadería', 1), -- 6
('Auditor', 'Consulta de reportes solo lectura', 1),                    -- 7
('Soporte', 'Mantenimiento técnico del sistema', 1);                    -- 8

-- 5. CLIENTE (fecha_nacimiento y email son NOT NULL; es_consumidor_final es BIT)
INSERT INTO cliente (nombre, apellido, dni, telefono, email, fecha_nacimiento, es_consumidor_final)
VALUES
('Ivan', 'Benitez', '46544211', '3794-123455', 'ivan.benitez@mail.com','2004-03-15', 1),
('Juan', 'Pérez', '30123456', '3794-123456', 'juan.perez@mail.com', '1984-07-22', 0),
('María', 'González', '28456789', '3794-234567', 'maria.gonzalez@mail.com','1981-11-05', 0),
('Carlos', 'Rodríguez', '33789012', '3794-345678', 'carlos.rodriguez@mail.com', '1988-02-18', 1),
('Lucía', 'Fernández', '35111222', '3777-456789', 'lucia.fernandez@mail.com','1991-09-30', 0),
('Martín', 'López', '29333444', '3794-567890', 'martin.lopez@mail.com', '1982-12-10', 1),
('Vinoteca', 'Del Centro SRL', '41234567', '3794-678901', 'compras@vinotecadelcentro.com', '1990-01-01', 0),
('Sofía', 'Martínez', '38555666', '3794-789012', 'sofia.martinez@mail.com', '1993-06-27', 1);

-- 6. METODO_PAGO (estado BIT: 1 = activo, 0 = inactivo)
INSERT INTO metodo_pago (nombre_metodo, estado) 
VALUES
('Efectivo', 1),
('Tarjeta de Débito', 1),
('Tarjeta de Crédito', 1),
('Transferencia Bancaria', 1),
('Mercado Pago', 1),
('Código QR', 1),
('Cheque', 0),
('Cuenta Corriente', 1);

-- 7. REGION (FK: pais)
INSERT INTO region (nombre, pais_id) 
VALUES
('Valle de Uco', 1),           -- Argentina
('Luján de Cuyo', 1),          -- Argentina
('Valles Calchaquíes', 1),     -- Argentina
('Valle del Maipo', 2),        -- Chile
('Canelones', 3),              -- Uruguay
('Rioja', 4),                  -- España
('Burdeos', 5),                -- Francia
('Toscana', 6);                -- Italia

-- 8. USUARIO (FK: rol)
INSERT INTO usuario (nombre, apellido, correo_electronico, contrasena, estado, fecha_registro, ultimo_inicio_sesion, rol_id)
VALUES
('Admin', 'Sistema', 'admin@vinoteca.com', 'ib918377', 'Activo', '2025-01-10 09:00:00', '2026-09-29 08:30:00', 1),
('Laura', 'Benítez', 'laura.benitez@vinoteca.com', '13131239', 'Activo', '2025-01-12 10:15:00', '2026-09-29 09:10:00', 2),
('Diego', 'Acosta', 'diego.acosta@vinoteca.com', '99012931', 'Activo', '2025-01-15 11:00:00', '2026-09-28 18:45:00', 3),
('Valeria', 'Romero', 'valeria.romero@vinoteca.com', '13910348', 'Activo', '2025-01-15 11:30:00', '2026-09-28 19:00:00', 4),
('Pablo', 'Sosa', 'pablo.sosa@vinoteca.com', '77819211', 'Activo', '2025-02-01 09:30:00', '2026-09-27 17:20:00', 5),
('Andrea', 'Molina', 'andrea.molina@vinoteca.com', '31344511', 'Activo', '2025-02-03 08:45:00', '2026-09-26 12:00:00', 6),
('Ricardo', 'Vega', 'ricardo.vega@vinoteca.com', '19038174', 'Inactivo', '2025-03-15 14:00:00', NULL, 7),
('Natalia', 'Duarte', 'natalia.duarte@vinoteca.com', 'sj910381', 'Activo', '2025-03-16 10:00:00', '2026-09-25 16:30:00', 8);