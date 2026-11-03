USE vinoteca;
GO

-- 1. CREADO DE LA TABLA DE AUDITORÍA
IF OBJECT_ID('dbo.Auditoria_Vino', 'U') IS NOT NULL
    DROP TABLE dbo.Auditoria_Vino;
GO

CREATE TABLE Auditoria_Vino (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    id_vino INT NOT NULL,
    precio_anterior DECIMAL(12,2),
    precio_nuevo DECIMAL(12,2),
    stock_anterior INT,
    stock_nuevo INT,
    usuario_modificacion VARCHAR(100) DEFAULT SUSER_SNAME(),
    fecha_modificacion DATETIME DEFAULT GETDATE(),
    tipo_operacion VARCHAR(10)
);
GO

-- 2. CREADO DEL TRIGGER DE AUDITORÍA
IF OBJECT_ID('dbo.trg_Auditoria_Vinos_Update', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Auditoria_Vinos_Update;
GO

CREATE TRIGGER trg_Auditoria_Vinos_Update
ON vino
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
  -- Solo inserta auditoría si hubo cambios en precio o stock
    IF UPDATE(precio_venta) OR UPDATE(stock_actual)
    BEGIN
        INSERT INTO Auditoria_Vino (
            id_vino,
            precio_anterior,
            precio_nuevo,
            stock_anterior,
            stock_nuevo,
            usuario_modificacion,
            fecha_modificacion,
            tipo_operacion
        )
        SELECT 
            d.id_vino,
            d.precio_venta AS precio_anterior,
            i.precio_venta AS precio_nuevo,
            d.stock_actual AS stock_anterior,
            i.stock_actual AS stock_nuevo,
            SUSER_SNAME(),
            GETDATE(),
            'UPDATE'
        FROM inserted i
        INNER JOIN deleted d ON i.id_vino = d.id_vino;
    END
END;
GO
