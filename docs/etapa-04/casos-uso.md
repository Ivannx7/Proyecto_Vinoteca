# Casos de uso de consultas SQL

## 1. Objetivo

En esta etapa se documentan las necesidades de información del sistema
de gestión de la vinoteca y las consultas SQL desarrolladas para
responderlas. Se busca facilitar la consulta de comprobantes, el
análisis de ventas y la evaluación comercial por bodega y región.

## 2. Entorno de trabajo

-   **Sistema gestor de base de datos:** Microsoft SQL Server.
-   **Base de datos:** `VINOTECA`.
-   **Lenguaje utilizado:** SQL (Structured Query Language).

Las consultas se documentan en archivos separados para facilitar su
lectura, ejecución y mantenimiento.

## 3. Casos de uso identificados

### 3.1. Consulta de comprobante de venta

-   **Actor:** personal autorizado de la vinoteca.
-   **Objetivo:** consultar los datos principales de una venta y los
    productos incluidos.
-   **Información obtenida:** número de venta, tipo de comprobante,
    fecha y hora, cliente, vendedor, vinos, cantidades, precios
    históricos, descuentos, subtotales y total de la venta.
-   **Tablas involucradas:** `venta`, `cliente`, `usuario`,
    `detalle_venta` y `vino`.
-   **Archivo relacionado:** `comprobante-venta.md`.

### 3.2. Informe agregado de ventas por categoría

-   **Actor:** administrador o encargado comercial.
-   **Objetivo:** analizar el rendimiento de las categorías de vino
    durante un rango de fechas.
-   **Información obtenida:** cantidad de operaciones, unidades vendidas
    y recaudación por categoría.
-   **Tablas involucradas:** `categoria`, `vino`, `detalle_venta` y
    `venta`.
-   **Archivo relacionado:** `informe-ventas.md`.

### 3.3. Análisis de negocio por bodega y región

-   **Actor:** administrador o responsable comercial.
-   **Objetivo:** comparar la cantidad de vinos ofrecidos, el precio
    promedio y los ingresos asociados a bodegas ubicadas en determinadas
    regiones.
-   **Información obtenida:** región, bodega, cantidad de vinos
    distintos con ventas, precio promedio, unidades vendidas e ingresos
    calculados.
-   **Tablas involucradas:** `region`, `bodega`, `vino` y
    `detalle_venta`. Para aplicar filtros de fechas o estado de la venta
    también debe relacionarse la tabla `venta`.
-   **Archivo relacionado:** `consulta-avanzada.md`.

## 4. Recursos SQL utilizados

-   **`JOIN`:** combina información de distintas tablas mediante sus
    relaciones.
-   **`CONCAT`:** une el nombre y el apellido de clientes y usuarios.
-   **`SUM`:** calcula acumulados, como unidades e ingresos.
-   **`COUNT(DISTINCT ...)`:** cuenta identificadores sin repetirlos
    dentro de cada grupo.
-   **`AVG`:** calcula el precio promedio.
-   **`GROUP BY`:** agrupa filas para calcular resultados por categoría,
    bodega o región.
-   **`HAVING`:** filtra grupos según el resultado de una función
    agregada.
-   **Subconsulta:** obtiene los identificadores de las regiones que
    cumplen con los nombres indicados.
-   **`CAST`:** convierte los importes a tipos decimales con la
    precisión definida.

## 5. Consideraciones de validación

Los resultados dependen de los datos que estén cargados en `VINOTECA`.
Cada consulta debe ejecutarse en SQL Server y comprobarse con los
registros reales.

