# Universidad Nacional del Nordeste

## Facultad de Ciencias Exactas y Naturales y Agrimensura

**Cátedra:** Base de Datos 1  
**Año:** 2026

# Sistema de gestión de ventas - Vinoteca

## Integrantes

- Benitez, Ivan Lautaro
- Ledesma, Daniela Agustina
- Maidana, Camila del Rosario
- Maidana, Catalina
- Meza, Bruno Fernando

---

# SISTEMA DE GESTIÓN DE VENTAS — VINOTECA

## Etapa I: Requerimientos y Dominio del Negocio

## 1. Descripción del Caso

El presente proyecto consiste en el desarrollo de un Sistema de Gestión de Ventas para una Vinoteca, un establecimiento comercial especializado en la comercialización de vinos. El sistema tiene como objetivo digitalizar y ordenar las operaciones centrales del negocio, brindando soporte a la administración de inventario, la atención a clientes, el procesamiento de ventas y el control interno de la información histórica de precios y transacciones.

El alcance funcional del sistema comprende la gestión del catálogo de productos, el registro y la administración de clientes, el procesamiento de ventas admitiendo múltiples medios de pago, el seguimiento histórico de precios con fines de auditoría, la generación de reportes de ventas y de estado de stock, y la administración de usuarios bajo un esquema de roles diferenciados (Gerente y Vendedor).

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

## 2. Reglas de Negocio

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
