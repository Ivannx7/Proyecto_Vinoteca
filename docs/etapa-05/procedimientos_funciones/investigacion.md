# Procedimientos Almacenados

## 1. Definición y objetivo
*  Definición: un Procedimiento Almacenado es un conjunto de sentencias compiladas y guardadas en el servidor de base de datos como un objeto reutilizable.
* Objetivo: Ejecutar operaciones complejas que involucran inserciones, actualizaciones, eliminaciones y lógica de negocio (como validaciones y control de errores) de manera centralizada y eficiente, evitando el envío de múltiples consultas desde la aplicación cliente.

## 2. Ventajas y Aplicaciones
* El servidor compila y optimiza el plan de ejecución la primera vez que se ejecuta.
* Permite conceder permisos de ejecución sobre el procedimiento a un usuario sin darle acceso directo a las tablas subyacentes. Previenen ataques de Inyección SQL.
* La lógica del sistema se modifica en un solo punto en la base de datos sin necesidad de redesplegar el software cliente.
* Registro de transacciones complejas (ventas, facturación), control de inventario y tareas administrativas estructuradas.

## 3. Implementación en SQL Server Express

En SQL Server Express, se implementan mediante el comando CREATE PROCEDURE. A diferencia de otros motores SQL:
* Las variables y parámetros inician con el símbolo @.
* El paso de parámetros se realiza mediante sintaxis @parametro = valor.
* El manejo de errores se gestiona con THROW o bloques BEGIN TRY ... BEGIN CATCH.
* No se utiliza la palabra reservada CALL, sino EXEC o EXECUTE.

## 4. Caso Concreto Aplicado al Sistema de Ventas

En el sistema de la vinoteca, los procedimientos encapsulan las siguientes reglas de negocio:
* sp_registrar_venta: Registra la cabecera e inserta la línea de detalle de la compra.
* sp_registrar_pago: Asocia el pago realizado a la venta.
* sp_actualizar_stock: Modifica la cantidad disponible de un vino en inventario.
* sp_actualizar_precio_vino: Modifica el precio unitario guardando la trazabilidad en la tabla historial_precio.
* sp_eliminar_registro: Elimina registros en tablas maestras validando restricciones de integridad referencial.

##  5. Resultados Obtenidos

Al ejecutar el script de demostración en SQL Server Management Studio (SSMS), se validan satisfactoriamente los siguientes puntos:

* Persistencia y Modificación Transaccional:
Las llamadas a sp_registrar_venta generan los IDs autonuméricos de venta e insertan los registros correspondientes en las tablas venta y detalle_venta.
sp_registrar_pago vincula correctamente los pagos realizados en venta_pago.
sp_actualizar_stock incrementa la cantidad en stock del vino según las unidades especificadas.
sp_actualizar_precio_vino registra el precio anterior en historial_precio con la estampa de tiempo actual (GETDATE()) y actualiza precio_venta en la tabla vino.

* Control de Seguridad e Integridad:
La llamada EXEC sp_eliminar_registro @p_tabla = 'categoria', @p_id = 5; efectúa el borrado únicamente tras validar que la tabla no sea de tipo transaccional/histórico y que el registro exista.
