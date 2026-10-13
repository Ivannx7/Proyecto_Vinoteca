# Implementación de la base de datos

## 1. Objetivo

En esta etapa se implementa la base de datos del sistema de gestión de una vinoteca, utilizando SQL Server. Se definen las tablas, sus atributos, las claves primarias y foráneas, y las restricciones necesarias para mantener la integridad de los datos.

Además, se realiza una carga inicial de datos de prueba para las entidades del sistema, permitiendo disponer de información para las consultas y las pruebas posteriores.

## 2. Lenguaje y entorno de implementación

- **Sistema gestor de base de datos:** Microsoft SQL Server.
- **Base de datos:** `VINOTECA`.
- **Lenguajes utilizados:** SQL DDL (Data Definition Language) y SQL DML (Data Manipulation Language).

Los scripts se encuentran organizados en las siguientes ubicaciones:

- `sql/ddl/vinoteca_ddl.sql`: definición y creación de las tablas.
- `sql/dml/vinoteca_dml.sql`: inserción de los datos iniciales.

## 3. Implementación de DDL

El script DDL crea las 15 tablas que componen la base de datos. Las entidades se organizan según sus dependencias y relaciones.

### 3.1. Entidades independientes y catálogos

Se crean las siguientes tablas:

- **cepa:** almacena las variedades de uva utilizadas en los vinos.
- **categoria:** registra las categorías de los vinos y sus descripciones.
- **pais:** almacena los países de origen.
- **rol:** define los roles y sus descripciones, fechas de creación y estados.
- **cliente:** registra los datos personales y de contacto de los clientes.
- **metodo_pago:** almacena los métodos de pago disponibles y su estado.

### 3.2. Entidades con dependencias

- **region:** registra regiones y las relaciona con un país mediante `id_pais`.
- **bodega:** almacena información de las bodegas y las relaciona con una región mediante `id_region`.
- **usuario:** registra los usuarios del sistema y los vincula con un rol mediante `id_rol`.
- **vino:** almacena los vinos, sus características, precios y existencias. Se relaciona con `id_categoria` y `id_bodega`.
- **vino_cepa:** resuelve la relación de muchos a muchos entre `vino` y `cepa`, mediante una clave primaria compuesta por `id_vino` e `id_cepa`.

### 3.3. Entidades transaccionales e históricas

- **venta:** registra las operaciones de venta, sus fechas, importes, comprobantes, clientes y usuarios responsables.
- **detalle_venta:** registra los vinos incluidos en cada venta, las cantidades, los precios históricos y los descuentos aplicados.
- **historial_precio:** registra las modificaciones de precios, incluyendo el precio anterior, el nuevo y el usuario responsable. Puede vincularse opcionalmente con un detalle de venta.
- **venta_pago:** registra los pagos asociados a las ventas y el método utilizado.

## 4. Implementación de DML

El script DML carga datos iniciales mediante sentencias `INSERT INTO`.

Se insertan ocho registros en cada una de las 15 tablas, para un total previsto de 120 registros iniciales si todas las inserciones se ejecutan correctamente en una base vacía y sin errores.

Los datos incluyen:

- Cepas, categorías y países.
- Roles, clientes y métodos de pago.
- Regiones, bodegas, usuarios y vinos.
- Relaciones entre vinos y cepas.
- Ventas y sus respectivos detalles.
- Historiales de precios y pagos.

La carga se realiza respetando las dependencias entre las tablas: primero se insertan los registros que serán referenciados y luego aquellos que contienen claves foráneas hacia ellos.

## 5. Resultado esperado

Al finalizar la implementación, la base de datos debe contar con las 15 tablas creadas, sus relaciones establecidas y los datos iniciales cargados.

La correcta ejecución de los scripts deberá verificarse mediante consultas de validación y pruebas de integridad documentadas en `pruebas-validacion.md`.