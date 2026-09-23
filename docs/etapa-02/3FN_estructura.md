Analizado la estructura de la vinoteca las entidades que cumplen las 3FN son:

## Venta
° 1FN: todos los valores de sus columnas (fecha, total, estado, etc.) son atómicos y posee clave primaria. No existen listas de productos ni grupos repetidos dentro de la cabecera de la venta.

° 2FN: Su clave primaria es simple (id_venta). Al no tener una clave primaria compuesta, cumple de manera automática ya que no existen dependencias parciales.

° 3FN: Todos sus atributos no clave (fecha, total, estado, id_cliente, id_usuario_vendedor, id_usuario_gerente_autoriza) dependen única y directamente del identificador de venta (id_venta). Ningún atributo no clave depende de otro que no sea la clave primaria y elimina la posibilidad de tener dependencias transitivas.

## Usuario 
°1FN: todos los atributos (nombre, email, contraseña, etc.) almacenan valores atómicos e indivisibles y posee clave primaria.

°2FN: su clave primaria es simple (id_usuario), por lo que satisface automáticamente ya que no existen dependencias parciales.

°3FN: Atributos como (nombre, email, estado) dependen directamente del usuario (id_usuario). La relación con el rol se manejan mediante su clave foránea (id_rol) sin duplicar información del rol.

## Rol
°1FN: sus atributos (nombre, descripción, etc.) almacenan valores atómicos e indivisibles y tiene clave primaria.

°2FN: su clave primaria es simple (id_rol), sin riesgo de dependencias parciales.

°3FN: atributos como (nombre_rol, descripción y estado) dependen única y directamente al rol identificado por (id_rol).

## Cliente
°1FN: cada columna (nombre, apellido, dni, email, etc.) almacena un valor único simple.

°2FN: tiene una clave primaria simple (id_cliente), estableciendo que no existan dependencias parciales.

°3FN: todos los datos personales corresponden de forma exclusiva al cliente identificado por (id_cliente).

## Categoría
°1FN: Los atributos de la categoría son atómicos (nombre_categoria, descripción) y posee clave primaria.

°2FN: su clave primaria simple (id_categoria) elimina la posibilidad de tener dependencias parciales.

°3FN: los atributos (nombre_categoria y descripción) dependen única y directamente del (id_categoria).

## Bodega
°1FN: contiene valores atómicos como (descripción, nombre, etc) y posee clave primaria.

°2FN: su clave primaria simple (id_bodega) elimina la posibilidad de tener dependencias parciales.

°3FN: El atributo (nombre) depende directamente de la bodega. Su ubicación geográfica se vincula mediante la clave foránea (id_region) evitando guardar datos descriptivos de la región o el país.

## País
°1FN: Los atributos de la categoría son atómicos y posee clave primaria.

°2FN: su clave primaria simple (id_pais) elimina la posibilidad de tener dependencias parciales.

°3FN: El atributo (nombre) depende única y directamente del (id_pais).

## Región
°1FN: Los atributos de la categoría son atómicos (región, nombre) y posee clave primaria.

°2FN: su clave primaria simple (id_region) elimina la posibilidad de tener dependencias parciales.

°3FN: El atributo (nombre) depende directamente del (id_region) y se vincula mediante la clave foránea (id_pais) evitando duplicar el nombre del país.

## Cepa
°1FN: Los atributos de la categoría son atómicos (cepa, nombre) y posee clave primaria.

°2FN: su clave primaria simple (id_cepa) elimina la posibilidad de tener dependencias parciales.

°3FN: El atributo (nombre) de la variedad de uva depende única y directamente de (id_cepa).

## VinoCepa
°1FN: Los valores en el porcentaje y en las claves son atómicos y posee clave primaria compuesta (id_vino, id_cepa).

°2FN: El atributo no clave (porcentaje) depende de la combinación completa del vino y la cepa (no se puede saber el porcentaje indicando solo el vino o solo la cepa)

°3FN: El atributo (porcentaje) depende directamente de la clave compuesta (id_vino, id_cepa) y no existen otros atributos no clave que generen dependencias transitivas.

## MetodoPago
°1FN: Los atributos de la categoría son atómicos (método_pago) y posee clave primaria.

°2FN: su clave primaria simple (id_metodo_pago) elimila la posibilidad de tener dependencias parciales.

°3FN: El atributo (método_pago) depende única y directamente del identificador del  método (id_metodo_pago).

## PagoVenta
°1FN: Los atributos de la categoría son atómicos (pago, venta, etc) y posee clave primaria.

°2FN: su clave primaria simple (id_pago) elimina la posibilidad de tener dependencias parciales.

°3FN: El atributo (monto) depende del registro de pago específico (id_pago), relacionándose con la transacción e instrumento de cobro mediante las claves foráneas (id_venta, id_metodo_pago).

## HistorialPrecio
°1FN: todos sus registros son atómicos y posee clave primaria.

°2FN: su clave primaria simple (id_historial) elimina la posibilidad de tener dependencias parciales.

°3FN: los atributos (precio_anterior, precio_nuevo y fecha_operacion) corresponden a un evento de cambio de precio identificado por (id_historial) manteniendo la referencia al vino mediante la clave foránea (id_vino).


Entidades que no cumplen las 3FN: 
## DetalleVenta

°1FN: todos sus atributos son atómicos (cantidad, precio_unitario_historico, etc.) y posee clave primaria.

°2FN: su clave primaria simple (id_detalle_venta) elimina la posibilidad de tener dependencias parciales.

°3FN: no cumple con la tercera forma normal ya que al contener el campo (subtotal) almacena un valor que resulta de un cálculo que produce datos derivados y redundantes.

## Solución
El campo (subtotal) debe eliminarse de la tabla y calcularse mediante una consulta cuando se requiera.

## Vinos
°1FN: todos sus atributos son atómicos (nombre, cosecha, etc.) y posee clave primaria.

°2FN: su clave primaria simple (sku) elimina la posibilidad de tener dependencias parciales.

°3FN: No cumple de forma estricta por falta de la clave foránea hacia bodega ya que aunque exista la tabla (bodega), la tabla (vinos) no almacena (id_bodega), impidiendo modelar la procedencia del producto. También porque se declara el campo id_categoria apuntando a categorías_producto, pero la tabla en el esquema se llama categoría.

## Solución
corregir el nombre de la clave foránea apuntando a Categoría(id_categoria) y agregar el campo id_bodega (FK->Bodega) en la tabla vinos.
