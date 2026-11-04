# Desarrollo del Tema: Optimización de Consultas a través de Índices

## Definición y Objetivo

Los índices son estructuras internas que el motor de base de datos (SQL Server) utiliza para buscar y localizar información de manera eficiente, funcionando de forma análoga al índice de un libro. Cuando una tabla maneja grandes volúmenes de datos, las consultas sin índices obligan al motor a realizar un **Table Scan** (recorrer toda la tabla fila por fila), elevando los costos de E/S y el tiempo de respuesta. El objetivo es implementar índices adecuados para transformar el escaneo completo en búsquedas directas (**Index Seek**), mejorando la escalabilidad del sistema.

&nbsp;

## Ventajas y Aplicaciones

- **Mejora del rendimiento:** Reduce notablemente los tiempos de respuesta en consultas de filtrado por fechas, rangos de precios o códigos.  
- **Disminución de lecturas lógicas:** Minimiza el impacto en la memoria y el uso de recursos de hardware.  
- **Aplicación en la Vinoteca:** Fundamental para optimizar los reportes analíticos de ventas por períodos de tiempo o estadísticas solicitadas por la gerencia.

&nbsp;

## 3\. Caso Concreto Aplicado al Sistema de la Vinoteca

Escenario: El sistema de la vinoteca registra operaciones de venta diariamente. Para evaluar el impacto de los índices, se implementa una tabla de prueba con un volumen significativo de registros adaptada a nuestro modelo de ventas.

### Script de Demostración (SQL Server):

```sql
USE VinotecaDB;
GO

-- Creación de tabla de pruebas
CREATE TABLE VentaHistorica
(
    id_venta BIGINT IDENTITY(1,1),
    fecha_venta DATE NOT NULL,
    importe DECIMAL (12,2) NOT NULL
);
GO

-- Carga masiva de datos simulados (1 millón de registros)
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
INSERT INTO VentaHistorica(fecha_venta, importe)
SELECT
    DATEADD(DAY, ABS (CHECKSUM(NEWID())) % 1825, '2020-01-01'),
    RAND(CHECKSUM(NEWID())) * 10000
FROM Numeros;
GO

-- Verificar cantidad de registros
SELECT COUNT(*) AS CantidadRegistros FROM VentaHistorica;
GO
```

&nbsp;

## Pruebas y Métricas de Rendimiento

### A. Consulta SIN Índices

Activamos las estadísticas de rendimiento en SSMS:

```sql
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

SELECT id_venta, fecha_venta, importe
FROM VentaHistorica
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';
GO
```

#### Métricas a registrar:

- Tiempo de CPU.  
- Tiempo total de ejecución.  
- Cantidad de lecturas lógicas.  
- Porcentaje de costo de la consulta.  
- Captura del plan de ejecución (**Table Scan**).

#### Ejemplo de documentación inicial:

| Medición | Valor |
| :---- | :---- |
| Tiempo CPU | 480 ms |
| Tiempo total | 545 ms&nbsp; |
| Lecturas lógicas | 4150 |
| Operación principal | Table Scan |

&nbsp;

### B. Creación de Índice Agrupado sobre la Fecha

```sql
CREATE CLUSTERED INDEX IX_VentaHistorica_Fecha
ON VentaHistorica (fecha_venta);
GO
```

*Nota: Repetir la consulta de prueba para registrar las nuevas métricas (cambiará a Index Seek o Seek \+ Lookup).*

&nbsp;

### C. Creación de Índice con Cobertura (No Agrupado)

```sql
-- Eliminar índice anterior si es necesario
DROP INDEX IF EXISTS IX_VentaHistorica_Fecha ON VentaHistorica;
GO

-- Crear índice con cobertura incluyendo el importe
CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
ON VentaHistorica (fecha_venta)
INCLUDE (importe);
GO

-- Ejecutar consulta optimizada
SELECT fecha_venta, importe
FROM VentaHistorica
WHERE fecha_venta BETWEEN '2023-01-01' AND '2023-03-31';
GO
```

&nbsp;

## Comparación Sugerida y Resultados Obtenidos

### Tabla comparativa de escenarios:

| Escenario | Tiempo (ms) | Lecturas Lógicas | Operación Principal |
| :---- | :---- | :---- | :---- |
| Sin índice | 545 ms | 4150 | Table Scan |
| Índice sobre fecha | 120 ms | 850 | Index Seek |
| Índice con cobertura | 45 ms | 175 | Index Seek |

&nbsp;

### Resultados esperados:

1. **Análisis masivo inicial:** La consulta sin índices requiere analizar una gran cantidad de registros mediante un recorrido completo de la tabla (*Table Scan*).  
2. **Impacto del índice por fecha:** El índice sobre la fecha reduce significativamente el trabajo realizado por el motor de base de datos transformándolo en búsquedas eficientes (*Index Seek*).  
3. **Optimización por cobertura:** El índice con cobertura disminuye aún más las lecturas lógicas necesarias para responder la consulta de forma directa, evitando accesos innecesarios a la tabla base.  
4. **Conclusión del plan físico:** Los planes de ejecución muestran un cambio fundamental desde operaciones de escaneo completo hacia búsquedas orientadas de alto rendimiento.