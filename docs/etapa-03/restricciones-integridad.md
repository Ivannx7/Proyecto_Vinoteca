# Restricciones de integridad

## 1. Objetivo

Este documento describe las restricciones de integridad definidas en la base de datos `VINOTECA`, destinadas a garantizar la identificación de los registros, la consistencia de las relaciones y la validez de determinados valores.

## 2. Claves primarias (PRIMARY KEY)

Todas las tablas cuentan con una clave primaria que identifica de forma única cada registro.

En las tablas principales, las claves se generan mediante `IDENTITY(1,1)`, que incrementa automáticamente el identificador.

La tabla `vino_cepa` utiliza una clave primaria compuesta por `id_vino` e `id_cepa`, evitando repetir la misma combinación de vino y cepa.

## 3. Claves foráneas (FOREIGN KEY)

Las claves foráneas aseguran que los registros relacionados hagan referencia a registros existentes.

| Tabla | Clave foránea | Tabla referenciada |
|---|---|---|
| `region` | `id_pais` | `pais` |
| `bodega` | `id_region` | `region` |
| `usuario` | `id_rol` | `rol` |
| `vino` | `id_categoria` | `categoria` |
| `vino` | `id_bodega` | `bodega` |
| `vino_cepa` | `id_vino` | `vino` |
| `vino_cepa` | `id_cepa` | `cepa` |
| `venta` | `id_cliente` | `cliente` |
| `venta` | `id_usuario` | `usuario` |
| `detalle_venta` | `id_vino` | `vino` |
| `detalle_venta` | `id_venta` | `venta` |
| `historial_precio` | `id_usuario` | `usuario` |
| `historial_precio` | `id_vino` | `vino` |
| `historial_precio` | `id_detalle_venta` | `detalle_venta` |
| `venta_pago` | `id_venta` | `venta` |
| `venta_pago` | `id_metodo_pago` | `metodo_pago` |

La columna `historial_precio.id_detalle_venta` admite valores nulos, por lo que un registro del historial de precios puede existir sin estar asociado a un detalle de venta.

## 4. Restricciones UNIQUE

Se definen las siguientes restricciones de unicidad:

- **`uq_usuario_correo`:** impide registrar dos usuarios con el mismo correo electrónico.
- **`uq_detalle_venta_vino`:** impide que un mismo vino aparezca en más de un detalle de una misma venta.

La segunda restricción permite que una venta contenga distintos vinos, pero no que el mismo vino se registre en dos filas separadas dentro de esa misma venta.

## 5. Restricciones CHECK

Se implementan las siguientes validaciones:

- **`chk_vino_precio`:** el precio de venta de un vino debe ser mayor o igual a cero.
- **`chk_vino_stock`:** el stock actual y el stock mínimo deben ser mayores o iguales a cero.
- **`chk_venta_monto`:** el monto total de una venta debe ser mayor o igual a cero.
- **`chk_detalle_venta_cantidad`:** la cantidad de unidades de un detalle de venta debe ser mayor que cero.
- **`chk_venta_pago_monto`:** el monto de un pago debe ser mayor que cero.

## 6. Valores obligatorios y valores predeterminados

Las columnas declaradas como `NOT NULL` no admiten valores nulos.

También se definen valores predeterminados mediante `DEFAULT`:

- El estado de un rol se inicializa en `1` (activo).
- El estado de un método de pago se inicializa en `1` (activo).
- El campo `cliente.es_consumidor_final` se inicializa en `1`.
- El stock actual y el stock mínimo de un vino se inicializan en `0`.
- El estado de un vino y de un usuario se inicializa en `'Activo'`.
- El porcentaje de descuento de un detalle de venta se inicializa en `0.00`.

Estos valores se aplican cuando se omite la columna correspondiente en una inserción y no se especifica otro valor predeterminado.

