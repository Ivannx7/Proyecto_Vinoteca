### Definición del alcance del catálogo de productos

Durante el relevamiento se evaluaron dos alternativas de diseño para el catálogo: (a) un catálogo genérico de bebidas, que admitiría vinos, cervezas, destilados y aperitivos bajo una única tabla de productos con atributos comunes (nombre, tamaño, precio); o (b) un catálogo especializado exclusivamente en vinos, donde cada producto incorpora de forma nativa los atributos enológicos que lo caracterizan (bodega, varietal, cosecha, región y país de origen).

Se optó por la segunda alternativa. La razón principal es de calidad de diseño: si el catálogo admitiera múltiples tipos de bebida sobre una misma tabla, los atributos propios del vino quedarían vacíos (NULL) para el resto de los productos —y viceversa—, lo cual atenta contra las buenas prácticas de modelado y dificulta sostener la Tercera Forma Normal sin introducir tablas de extensión adicionales. Al restringir el dominio exclusivamente a vinos, coherente además con el nombre y el rubro del negocio ("Vinoteca"), todos los productos comparten el mismo conjunto de atributos obligatorios, lo que simplifica el modelo, evita nulos estructurales y mantiene la integridad y consistencia de los datos.

En consecuencia, el sistema administrará un catálogo compuesto por cuatro categorías de vino:

- Vinos Tintos
- Vinos Blancos
- Vinos Rosados
- Espumantes

### Alcance incluido

- Gestión de inventario de productos (vinos).
- Registro y administración de clientes.
- Procesamiento de ventas con uno o múltiples métodos de pago.
- Seguimiento histórico e inmutable de precios unitarios, para auditoría.
- Trazabilidad de las modificaciones de precio de catálogo.
- Control de stock mínimo y alertas de reposición.
- Administración de usuarios mediante un esquema de roles y permisos.
- Anulación de ventas con restitución automática de stock.

### Alcance excluido

- Comercialización de bebidas no vínicas (cervezas, destilados, aperitivos) u otros productos ajenos al rubro.
- Gestión de compras a proveedores y logística de reposición (fuera del alcance de esta etapa).
- Facturación electrónica y su integración con organismos fiscales.
- Comercio electrónico o canales de venta online.
