USE vinoteca;

ALTER TABLE cliente
ADD telefono VARCHAR(50) NULL,
    consumidor_final BIT NOT NULL CONSTRAINT df_cliente_consumidor DEFAULT 1;