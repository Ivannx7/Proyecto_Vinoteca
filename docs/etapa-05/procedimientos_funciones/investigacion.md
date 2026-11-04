## 1. Procedimientos Almacenados

# Definición y objetivo
*  Definición: un Procedimiento Almacenado es un conjunto de sentencias Transact-SQL (T-SQL) compiladas y guardadas en el servidor de base de datos como un objeto reutilizable.
* Objetivo: Ejecutar operaciones complejas que involucran inserciones, actualizaciones, eliminaciones y lógica de negocio (como validaciones y control de errores) de manera centralizada y eficiente, evitando el envío de múltiples consultas desde la aplicación cliente.

# Ventajas y Aplicaciones
* El servidor compila y optimiza el plan de ejecución la primera vez que se ejecuta.
* Permite conceder permisos de ejecución sobre el procedimiento a un usuario sin darle acceso directo a las tablas subyacentes. Previenen ataques de Inyección SQL.
* La lógica del sistema se modifica en un solo punto en la base de datos sin necesidad de redesplegar el software cliente.
* Registro de transacciones complejas (ventas, facturación), control de inventario y tareas administrativas estructuradas.

# Implementación en SQL Server Express

En SQL Server Express, se implementan mediante el comando CREATE PROCEDURE. A diferencia de otros motores SQL:
* Las variables y parámetros inician con el símbolo @.
* El paso de parámetros se realiza mediante sintaxis @parametro = valor.
* El manejo de errores se gestiona con THROW o bloques BEGIN TRY ... BEGIN CATCH.
* No se utiliza la palabra reservada CALL, sino EXEC o EXECUTE.

# Caso Concreto Aplicado al Sistema de Ventas

En el sistema de la vinoteca, los procedimientos encapsulan las siguientes reglas de negocio:
* sp_registrar_venta: Registra la cabecera e inserta la línea de detalle de la compra.
* sp_registrar_pago: Asocia el pago realizado a la venta.
* sp_actualizar_stock: Modifica la cantidad disponible de un vino en inventario.
* sp_actualizar_precio_vino: Modifica el precio unitario guardando la trazabilidad en la tabla historial_precio.
* sp_eliminar_registro: Elimina registros en tablas maestras validando restricciones de integridad referencial.

## Funciones Almacenadas

# Definición y Objetivo

* Definición: una Función Almacenada Escalar es una rutina reutilizable que recibe parámetros de entrada, ejecuta un cálculo determinista y devuelve un único valor escalar (por ejemplo, DECIMAL, INT).
* Objetivo: Encapsular fórmulas matemáticas, transformaciones de datos o reglas de cálculo repetitivas dentro del motor de base de datos para consumirlas dentro de consultas SELECT, cláusulas WHERE o procedimientos.

## Ventajas y Aplicaciones

* Evita duplicar código de fórmulas en distintas consultas del sistema.
* Se integran de forma transparente dentro de sentencias SELECT, UPDATE o dentro de procedimientos almacenados.
* Cálculo de subtotales, precios finales con descuento, cálculo de impuestos (IVA), o conversión de divisas.

## Implementación en SQL Server Express

* Se crean con CREATE FUNCTION ... RETURNS <tipo_dato>.
* Es obligatorio que contengan la cláusula RETURNS y un bloque BEGIN ... END que finalice con RETURN <valor>.
* Regla crítica en SQL Server: Para invocarlas en cualquier consulta es obligatorio anteponer el esquema del objeto (ejemplo: dbo.fn_calcular_subtotal(...)).

## Caso Concreto Aplicado al Sistema de Ventas

* fn_calcular_subtotal: Multiplica la cantidad de unidades por el precio unitario del vino.
* fn_calcular_precio_con_descuento: Toma el precio original y descuenta el porcentaje indicado para retornar el nuevo precio de venta.
* 
5. Resultados Obtenidos

Al ejecutar el script de demostración en SQL Server Management Studio (SSMS), se validan satisfactoriamente los siguientes puntos:

* Persistencia y Modificación Transaccional:
Las llamadas a sp_registrar_venta generan los IDs autonuméricos de venta e insertan los registros correspondientes en las tablas venta y detalle_venta.
sp_registrar_pago vincula correctamente los pagos realizados en venta_pago.
sp_actualizar_stock incrementa la cantidad en stock del vino según las unidades especificadas.
sp_actualizar_precio_vino registra el precio anterior en historial_precio con la estampa de tiempo actual (GETDATE()) y actualiza precio_venta en la tabla vino.

* Control de Seguridad e Integridad:
La llamada EXEC sp_eliminar_registro @p_tabla = 'categoria', @p_id = 5; efectúa el borrado únicamente tras validar que la tabla no sea de tipo transaccional/histórico y que el registro exista.
Cálculos Escalares Exactos:
Las consultas SELECT dbo.fn_calcular_subtotal(...) retornan valores precisos redondeados a dos decimales (90000.00, 12005.00, 111004.50).
Las consultas SELECT dbo.fn_calcular_precio_con_descuento(...) calculan correctamente los valores con descuento (18000.00, 37500.00, 60000.00).
