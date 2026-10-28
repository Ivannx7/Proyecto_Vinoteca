##  Reglas de Negocio

A continuación se detallan las reglas de negocio que rigen las operaciones del sistema. Cada regla fue redactada de manera explícita, incorporando los criterios y supuestos resueltos por el equipo de trabajo.

### RN-01 Gestión de Stock

El sistema impedirá registrar la venta de cualquier producto si la cantidad solicitada es mayor al stock_actual disponible en góndola o depósito.

### RN-02 Registro de Clientes

Toda venta registrada en el sistema debe estar vinculada obligatoriamente a un cliente.

- **Ventas nominales:** si el cliente brinda sus datos, la venta se asocia a su registro individual.
- **Consumidor Final:** para ventas ocasionales de mostrador donde no se identifique al comprador, la venta se asigna automáticamente a un registro genérico denominado "Consumidor Final".

### RN-03 Historial de Precios Unitarios en el Detalle de Venta

Cada línea de detalle de una venta debe registrar el precio unitario vigente al momento de la transacción, asegurando que cambios futuros en el catálogo no alteren el total de ventas pasadas. Este valor es inmutable y no puede ser modificado retroactivamente, garantizando auditoría y transparencia.

### RN-04 Métodos de Pago

El pago de la venta se registrará únicamente utilizando uno o mas de los métodos predefinidos y habilitados en la base de datos.

- **Métodos de pago disponibles:** Efectivo, Débito, Crédito, Transferencia Bancaria, Billetera Digital (QR).
- Una venta puede abonarse con un único método o combinando varios; la suma de los montos ingresados por cada método debe igualar exactamente el total de la venta para poder finalizarla.
- Toda transacción de pago se registra con fecha, hora exacta y usuario que la procesó.

### RN-05 Clasificación del Inventario y Atributos Enológicos

Cada vino comercializado debe pertenecer a una Categoría y estar asociado a su bodega de origen.

- **Categorías admitidas:** Vinos Tintos, Vinos Blancos, Vinos Rosados, Espumantes.
- Todo producto debe incluir obligatoriamente los datos enológicos: bodega, varietal (cepa), cosecha (añada), región y país de origen.
- Todo producto cuenta además con: SKU (código único), nombre, descripción, precio de venta, costo y estado (Activo/Inactivo).

### RN-06 Control de Stock Mínimo y Alerta de Reposición

Un producto pasará automáticamente a estado de "Stock Crítico" cuando su stock_actual sea menor o igual a su stock_mínimo.

- El valor de stock_mínimo debe ser siempre un número entero mayor o igual a cero.
- El sistema notificará las etiquetas en estado de stock crítico para su rápida reposición.

### RN-07 Control de Accesos (Roles)

El sistema implementa un modelo de control de acceso basado en roles, que define qué operaciones puede realizar cada usuario. Cada usuario posee un rol único (Gerente o Vendedor), y cada rol determina el conjunto de permisos habilitados sobre las distintas funcionalidades.

### RN-08 Trazabilidad de Precios

Toda modificación en el precio vigente de un producto genera automáticamente un registro que detalla el precio anterior, el nuevo precio y la fecha y hora exacta del cambio.

### RN-09 Restricción de Venta de Productos Inactivos

Los vinos con estado "Inactivo" en el catálogo quedan inhabilitados para cualquier operación comercial: no podran seleccionarse ni agregarse a nuevas ventas o presupuestos.

### RN-10 Descuento Automático por Venta en Caja (6 o más Unidades)

Si en una venta la cantidad agregada de un mismo SKU es igual o múltiplo de 6 unidades (caja cerrada), el sistema aplicará automáticamente un porcentaje de descuento predefinido sobre el precio unitario de ese renglón. El descuento se calcula de forma explícita en el detalle de venta y queda registrado en la transacción.

### RN-11 Anulación de Ventas y Restitución de Stock

La anulación de una venta ya completada requiere autorización del Gerente. Al concretarse la anulación, el sistema reintegra automáticamente las unidades vendidas al stock_actual del vino correspondiente.

### RN-12 Restricción Legal por Mayoría de Edad

La venta de bebidas alcohólicas está legalmente restringida a personas mayores de 18 años. En el registro de clientes nuevos para ventas nominativas, la fecha de nacimiento ingresada debe certificar la mayoría de edad para habilitar la operación.
