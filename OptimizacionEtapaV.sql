-- =================================================================د
-- PASO 1: Seleccionar la base de datos y preparar entorno de pruebas
-- =================================================================
USE VinotecaDB;
GO

-- Si querés simular el volumen masivo de la guía sobre una tabla de prueba de ventas:
CREATE TABLE VentaHistoricaVinoteca
(
    id_venta BIGINT IDENTITY(1,1),
    fecha_venta DATE NOT NULL,
    monto_total DECIMAL (12,2) NOT NULL
);
GO

-- Carga masiva de datos simulados (registros de prueba)
SET NOCOUNT ON;
GO

WITH Numeros AS
(
    SELECT TOP (1000000)
        ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
    CROSS JOIN sys.objects c
)
INSERT INTO VentaHistoricaVinoteca(fecha_venta, monto_total)
SELECT
    DATEADD(DAY, ABS (CHECKSUM(NEWID())) % 1825, '2020-01-01'),
    RAND(CHECKSUM(NEWID())) * 10000
FROM Numeros;
GO

-- Verificar cantidad de registros cargados
SELECT COUNT(*) AS CantidadRegistros FROM VentaHistoricaVinoteca;
GO

-- =================================================================
-- PASO 2: Consulta SIN ÍNDICES (Medición inicial)
-- =================================================================
-- Activamos las estadísticas de rendimiento y el plan de ejecución real
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- Consulta de análisis de ventas por rango de fechas
SELECT id_venta, fecha_venta, monto_total
FROM VentaHistoricaVinoteca
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';
GO

-- =================================================================
-- PASO 3: Creación de un Índice con Optimización
-- =================================================================
-- Creamos un índice no agrupado sobre la fecha e incluimos el monto total
CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
ON VentaHistoricaVinoteca (fecha_venta)
INCLUDE (monto_total);
GO

-- =================================================================
-- PASO 4: Consulta CON ÍNDICE (Medición final)
-- =================================================================
-- Volvemos a ejecutar la misma consulta para evaluar la mejora
SELECT id_venta, fecha_venta, monto_total
FROM VentaHistoricaVinoteca
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';
GO