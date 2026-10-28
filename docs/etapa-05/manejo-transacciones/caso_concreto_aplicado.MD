# 4. Caso Concreto Aplicado al Sistema de Ventas

Para la demostración práctica en el sistema de gestión de la vinoteca, se ha seleccionado el escenario de **Registro Atómico de Venta con Validación de Stock**. Este es el proceso más crítico del negocio, ya que involucra la afectación concurrente de ingresos financieros y egresos de inventario.

## Descripción del Escenario

Cuando un cliente se presenta en el mostrador o finaliza un pedido por e-commerce, el sistema debe registrar la transacción comercial. Este hecho de negocio requiere insertar datos en las tablas de comprobantes y, simultáneamente, actualizar el catálogo de productos. 

Si el cajero escanea tres botellas de vino diferentes, el sistema no puede permitirse guardar la cabecera del ticket y solo dos de los tres detalles debido a un error temporal, ni tampoco puede descontar el stock si la venta finalmente no se concreta.

## Entidades Involucradas (Según el DER del proyecto)
El Procedimiento Almacenado transaccional interactuará de forma centralizada con las siguientes entidades:
1.  **`Venta`**: Para registrar la cabecera (fecha, total, estado, cliente y usuario).
2.  **`Detalle`**: Entidad débil que almacena cada renglón de la factura (cantidad, precio histórico y descuentos).
3.  **`Vino`**: Catálogo de productos donde se debe actualizar el atributo `stock_actual`.

## Secuencia Lógica de la Transacción (Unidad Lógica de Trabajo)

El caso de uso se diseñó para ejecutarse bajo el siguiente flujo estrictamente controlado por las sentencias `BEGIN TRY` y `BEGIN TRAN`:

1.  **Inicio de la Operación:** La aplicación envía los datos de la venta al motor SQL Server.
2.  **Apertura de la Transacción:** Se inicia el bloqueo lógico de los datos.
3.  **Inserción de Cabecera:** Se ejecuta un `INSERT` en la tabla `Venta` y se recupera el ID generado (mediante `SCOPE_IDENTITY()`).
4.  **Iteración de Detalles e Inventario:** Por cada artículo en el carrito del cliente:
    *   Se ejecuta un `UPDATE` en la tabla `Vino` restando la `cantidad` vendida al `stock_actual`.
    *   Se valida la restricción de negocio: *¿El stock resultante es mayor o igual a 0?*
    *   Se ejecuta un `INSERT` en la tabla `Detalle` vinculándolo al ID de la cabecera.
5.  **Resolución (Propiedad de Atomicidad):**
    *   **Escenario de Éxito (`COMMIT`):** Si todas las validaciones pasan y no hay errores de conexión, la transacción se confirma. La venta se considera cerrada y el stock actualizado.
    *   **Escenario de Falla (`ROLLBACK`):** Si durante el paso 4 el sistema detecta que se intentó vender una cantidad mayor al `stock_actual` disponible (o si ocurre un error de base de datos), la ejecución salta al bloque `CATCH`. Se revierte toda la operación, la cabecera generada en el paso 3 desaparece y los stocks parciales descontados vuelven a su estado original, dejando la base de datos completamente limpia y consistente.

Este caso concreto demuestra cómo el motor de SQL Server asume la responsabilidad de la **consistencia** y el **aislamiento** de los datos, liberando a la capa de presentación de tener que lidiar con la limpieza manual de registros huérfanos.