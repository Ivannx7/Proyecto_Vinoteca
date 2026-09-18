# SISTEMA DE GESTIÓN DE VENTAS \- VINOTECA

### Estructura&nbsp;

#### Tabla: `Usuario`

- id\_usuario (PK)  
- nombre  
- email (UNIQUE)  
- contraseña (hasheada)  
- id\_rol (FK → roles)  
- estado (Activo/Inactivo)  
- fecha\_creacion  
- fecha\_ultimo\_acceso

#### Tabla: `Rol`

- id\_rol (PK)  
- nombre\_rol (UNIQUE)  
- descripción  
- estado (Activo/Inactivo)

#### Tabla: `Cliente`

- id\_cliente (PK)  
- nombre  
- apellido  
- dni (UNIQUE)  
- email  
- fecha\_nacimiento

#### Tabla: `Categoria`

- id\_categoria (PK)  
- nombre\_categoria&nbsp;  
- descripción

#### Tabla: `Vinos`

- sku (PK)  
- nombre  
- cosecha  
- descripción  
- grados\_alcohol  
- id\_categoria (FK → categorias\_producto)  
- precio\_venta  
- precio\_costo  
- stock\_actual  
- stock\_mínimo  
- estado&nbsp;

#### Tabla: `Bodega`

- id\_bodega (PK)  
- nombre  
- region\_id(FK)

#### Tabla: `Pais`

- pais\_id(PK)  
- nombre

#### Tabla: `Region`

- region\_id(PK)  
- nombre  
- pais\_id(FK)

#### Tabla: `Cepa`

- id\_cepa (PK)  
- nombre

#### Tabla: `VinoCepa`

- id\_vino (FK)  
- id\_cepa (FK)  
- porcentaje

#### Tabla: `Venta`

- id\_venta (PK)  
- fecha  
- id\_cliente (FK → clientes) \[NULL para clientes ocasionales\]  
  `crear un registro físico en la tabla Cliente llamado "Consumidor Final" (por ejemplo, con ID 1 o 99999999) y asignarle ese ID`  
- id\_usuario\_vendedor (FK → usuarios)  
- id\_usuario\_gerente\_autoriza (cancelar venta)  
- total  
- estado (Completada/Cancelada/Anulada)

#### Tabla: `DetalleVenta`

- id\_detalle\_venta (PK)  
- id\_venta (FK → ventas)  
- id\_producto (FK → productos)  
- cantidad  
- precio\_unitario\_historico  
- porcentaje\_descuento&nbsp;  
- subtotal&nbsp;

#### Tabla: `MetodoPago`&nbsp;

- id\_metodo\_pago (PK)  
- método\_pago (Efectivo/Débito/Crédito/Transferencia/Billetera)

&nbsp;

#### Tabla: `PagoVenta (RN-04)`

- id\_pago  
- id\_venta (FK)  
- id\_metodo\_pago  
- monto

#### Tabla: `HistorialPrecio  (plantear mas RN-08)`

- id\_historial (PK)  
- id\_vino (FK)  
- precio\_anterior  
- precio\_nuevo&nbsp;  
- fecha\_operación  
- id\_usuario (FK) ?  
  &nbsp;
