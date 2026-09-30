USE VINOTECA
GO

--DML
-- 1. CEPA
INSERT INTO cepa (nombre) VALUES
('Malbec'),
('Cabernet Sauvignon'),
('Merlot'),
('Syrah'),
('Bonarda'),
('Tempranillo'),
('Torrontés'),
('Chardonnay');

-- 2. CATEGORIA
INSERT INTO categoria (nombre_categoria, descripcion) VALUES
('Tinto', 'Vinos elaborados con uvas tintas'),
('Blanco', 'Vinos elaborados con uvas blancas'),
('Rosado', 'Vinos de maceración corta con uvas tintas'),
('Espumante', 'Vinos con burbujas, método charmat o champenoise'),
('Vino de Postre', 'Vinos dulces o de cosecha tardía'),
('Reserva', 'Vinos con crianza en barrica y botella'),
('Gran Reserva', 'Vinos de larga crianza y guarda'),
('Orgánico', 'Vinos de viñedos con certificación orgánica');

-- 3. PROVINCIA
INSERT INTO provincia (nombre) VALUES
('Mendoza'),      
('Corrientes'),    
('Salta'),       
('La Rioja'),     
('Neuquén'),      
('Río Negro'),    
('Catamarca'),   
('Jujuy');       

-- 4. ROL
INSERT INTO rol (nombre, descripcion, fecha_creacion) VALUES
('Administrador', 'Acceso total al sistema', '2025-01-10'),                  -- 1
('Gerente', 'Autoriza descuentos y anulaciones', '2025-01-10'),              -- 2
('Vendedor', 'Registra ventas y atiende clientes', '2025-01-10'),            -- 3
('Cajero', 'Registra pagos y emite comprobantes', '2025-01-10'),             -- 4
('Sommelier', 'Asesora en la selección de vinos', '2025-02-01'),             -- 5
('Encargado de depósito', 'Gestiona stock y recepción de mercadería', '2025-02-01'), -- 6
('Auditor', 'Consulta de reportes solo lectura', '2025-03-15'),              -- 7
('Soporte', 'Mantenimiento técnico del sistema', '2025-03-15');              -- 8

-- 5. CLIENTE
INSERT INTO cliente (nombre, apellido, dni, telefono, correo_electronico, es_consumidor_final) 
VALUES
('Ivan', 'Benitez', '46544211', '3794-123455', 'ivan.benitez@mail.com', 1),
('Juan', 'Pérez', '30123456', '3794-123456', 'juan.perez@mail.com', 0),
('María', 'González', '28456789', '3794-234567', 'maria.gonzalez@mail.com', 0),
('Carlos', 'Rodríguez', '33789012', '3794-345678', 'carlos.rodriguez@mail.com', 1),
('Lucía', 'Fernández', '35111222', '3777-456789', 'lucia.fernandez@mail.com', 0),
('Martín', 'López', '29333444', '3794-567890', NULL, 1),
('Vinoteca', 'Del Centro SRL','41234567', '3794-678901', 'compras@vinotecadelcentro.com', 0),
('Sofía', 'Martínez', '38555666', '3794-789012', 'sofia.martinez@mail.com', 1);

-- 6. METODO_PAGO
INSERT INTO metodo_pago (nombre_metodo, estado) VALUES
('Efectivo', 'Activo'),
('Tarjeta de Débito', 'Activo'),
('Tarjeta de Crédito', 'Activo'),
('Transferencia Bancaria', 'Activo'),
('Mercado Pago', 'Activo'),
('Código QR', 'Activo'),
('Cheque', 'Inactivo'),
('Cuenta Corriente', 'Activo');

-- 7. REGION (FK: provincia)
INSERT INTO region (nombre, id_provincia) VALUES
('Valle de Uco', 1),               -- Mendoza
('Luján de Cuyo', 1),              -- Mendoza
('Capital', 2),                    -- Corrientes
('Valles Calchaquíes', 3),         -- Salta
('Valle de Famatina', 4),          -- La Rioja
('San Patricio del Chañar', 5),    -- Neuquén
('Alto Valle de Río Negro', 6),    -- Río Negro
('Quebrada de Humahuaca', 8);      -- Jujuy

-- 8. USUARIO (FK: rol)
INSERT INTO usuario (nombre, apellido, correo_electronico, contrasena, estado, fecha_registro, ultimo_inicio_sesion, id_rol) 
VALUES
('Admin', 'Sistema', 'admin@vinoteca.com', 'ib918377', 'Activo', '2025-01-10 09:00:00', '2026-09-29 08:30:00', 1),
('Laura', 'Benítez', 'laura.benitez@vinoteca.com', '13131239', 'Activo', '2025-01-12 10:15:00', '2026-09-29 09:10:00', 2),
('Diego', 'Acosta', 'diego.acosta@vinoteca.com', '99012931', 'Activo', '2025-01-15 11:00:00', '2026-09-28 18:45:00', 3),
('Valeria', 'Romero', 'valeria.romero@vinoteca.com', '13910348', 'Activo', '2025-01-15 11:30:00', '2026-09-28 19:00:00', 4),
('Pablo', 'Sosa', 'pablo.sosa@vinoteca.com', '77819211', 'Activo', '2025-02-01 09:30:00', '2026-09-27 17:20:00', 5),
('Andrea', 'Molina', 'andrea.molina@vinoteca.com', '31344511', 'Activo', '2025-02-03 08:45:00', '2026-09-26 12:00:00', 6),
('Ricardo', 'Vega', 'ricardo.vega@vinoteca.com', '19038174', 'Inactivo', '2025-03-15 14:00:00', NULL, 7),
('Natalia', 'Duarte', 'natalia.duarte@vinoteca.com', 'sj910381', 'Activo', '2025-03-16 10:00:00', '2026-09-25 16:30:00', 8);