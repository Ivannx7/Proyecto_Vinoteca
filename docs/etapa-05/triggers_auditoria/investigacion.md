Investigación: Triggers de Auditoría

1. Definición y Objetivo
Un trigger o disparador en SQL Server es un procedimiento almacenado especial que se ejecuta automáticamente cuando
ocurre un evento de modificación de datos (`INSERT`, `UPDATE` o `DELETE`) sobre una tabla específica.

El objetivo principal de un trigger de auditoría es registrar y guardar de forma automática y transparente la trazabilidad
de los cambios realizados en los datos sensibles del sistema (como modificaciones de precios o variaciones de stock), 
sin necesidad de que la aplicación cliente ejecute lógica adicional.

2. Ventajas y Aplicaciones
Ventajas:
Automatización total: Se dispara a nivel de base de datos independientemente de dónde provenga la modificación
(aplicación web, script manual, etc.).
Integridad y Seguridad: Evita la alteración o pérdida no detectada de información histórica sensible.
Transparencia: Funciona en segundo plano sin alterar el flujo normal de las operaciones de negocio.

Aplicaciones en la Vinoteca:
Auditoría de precios: Registrar automáticamente quién, cuándo y cuánto cambió el precio de los vinos del catálogo.
Control de stock: Mantener un historial de ajustes manuales o modificaciones críticas en las existencias de productos.

3. Implementación en SQL Server Express
En SQL Server Express, los triggers de auditoría se implementan capturando el evento deseado (`AFTER UPDATE`, `AFTER DELETE`, etc.).
Durante la ejecución del trigger, el motor crea y utiliza dos tablas lógicas temporales en memoria:
* **`inserted`:** Almacena las filas con los nuevos valores ingresados o modificados.
* **`deleted`:** Almacena las filas con los valores antiguos antes de ser modificados o eliminados.

Mediante una consulta interna entre `inserted` y `deleted`, el trigger extrae la diferencia y guarda el registro 
histórico en la tabla de auditoría correspondiente.

4. Caso Concreto Aplicado al Sistema de Ventas (Vinoteca)
Escenario de negocio: En la vinoteca es fundamental auditar las modificaciones en los precios de los vinos y en los ajustes
de stock para evitar inconsistencias o manipulaciones no autorizadas.

**Solución diseñada:**
1. **Tabla de auditoría:** `Auditoria_Vino`, encargada de almacenar el ID del vino, precio/stock anterior, precio/stock nuevo,
usuario que realizó la modificación y la fecha/hora exacta.
2. **Trigger:** `trg_Auditoria_Vinos_Update`, configurado sobre la tabla `Vino` para dispararse `AFTER UPDATE` únicamente
cuando varíen las columnas de precio o stock.

5. Script de Demostración y Resultados Esperados
*El código completo del trigger y la creación de la tabla de auditoría se encuentran en el archivo `scripts.sql` de esta misma carpeta.*

### Flujo de Prueba:
1. Se consulta el estado actual de un producto en la tabla `Vino`.
2. Se ejecuta una sentencia de actualización (`UPDATE`) modificando el precio del vino.
3. Se realiza una consulta `SELECT * FROM Auditoria_Vino` para verificar que el trigger registró automáticamente el cambio con los valores anteriores, los nuevos, el usuario del sistema y la fecha actual.
