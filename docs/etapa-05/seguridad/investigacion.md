# Seguridad: manejo de permisos a nivel de usuarios y roles en SQL Server

**Base de datos:** `VINOTECA`  
**Script asociado:** seguridad/`scripts.sql`


## 1. Introducción

La seguridad en una base de datos permite controlar qué usuarios pueden acceder a la información y qué operaciones pueden realizar. SQL Server permite asignar permisos directamente a cada usuario o agruparlos en **roles**, aplicando el **principio de mínimo privilegio**: cada usuario recibe únicamente los permisos necesarios para realizar sus tareas.

Conceptos utilizados:

- **LOGIN:** cuenta que permite autenticarse en el servidor SQL Server.
- **USER:** identidad asociada a un login dentro de una base de datos; sobre ella se asignan permisos.
- **ROLE:** conjunto de permisos que puede asignarse a uno o varios usuarios, facilitando la administración de los accesos.
- **EXECUTE AS USER / REVERT:** `EXECUTE AS USER` cambia temporalmente el contexto de ejecución al usuario indicado y `REVERT` permite volver al contexto original.

**Aclaración:** las tablas `usuario` y `rol` que puedan existir en el modelo de negocio son objetos de la aplicación. Los logins, usuarios y roles de este documento son objetos de seguridad de SQL Server y no deben confundirse con los anteriores.

## 2. Verificación del modo de autenticación

Se verifica que SQL Server esté configurado en modo de autenticación mixto, que permite conectarse mediante autenticación de Windows y mediante usuarios de SQL Server.

```sql
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') AS SoloWindows;
```

Interpretación del resultado:

- `0`: autenticación en modo mixto (Windows y SQL Server).
- `1`: solamente autenticación de Windows.

**Resultado obtenido:** el resultado fue `0`, el servidor está configurado en modo mixto


## 3. Permisos a nivel de usuarios

En este escenario se crean dos usuarios con distintos privilegios: uno con permisos de administrador y otro con permisos de lectura sobre la tabla `Venta`. Además, se permite que el usuario lector ejecute un procedimiento almacenado específico.

### 3.1. Creación de usuarios y asignación de permisos

Se crean los logins y sus usuarios correspondientes dentro de la base de datos `VINOTECA`. Luego se asignan los siguientes permisos:

| Usuario | Perfil | Permisos asignados |
|---|---|---|
| `usuario_admin` | Administrador | Miembro del rol `db_owner`, con control total sobre la base de datos. |
| `usuario_lector` | Solo lectura | `SELECT` sobre `dbo.Venta` y `EXECUTE` sobre `dbo.sp_RegistrarVenta`. |

Los permisos principales utilizados son:

```sql
ALTER ROLE db_owner ADD MEMBER usuario_admin;

GRANT SELECT ON dbo.Venta TO usuario_lector;
GRANT EXECUTE ON dbo.sp_RegistrarVenta TO usuario_lector;
```

**Resultado obtenido:** Los comandos se han completado correctamente.





### 3.2. Prueba de INSERT directo sobre `Venta`

Se comprueba si ambos usuarios pueden insertar registros directamente en la tabla `Venta`.

La operación se ejecuta con el contexto de cada usuario mediante `EXECUTE AS USER` y, al finalizar, se utiliza `REVERT` para regresar al contexto original.

```sql
-- Prueba con el administrador
EXECUTE AS USER = 'usuario_admin';

INSERT INTO Venta (fecha_hora, monto_total, tipo_comprobante, id_cliente, id_usuario)
VALUES (GETDATE(), 15000, 'Ticket', 2, 3);

REVERT;

-- Prueba con el lector
EXECUTE AS USER = 'usuario_lector';

INSERT INTO Venta (fecha_hora, monto_total, tipo_comprobante, id_cliente, id_usuario)
VALUES (GETDATE(), 15000, 'Ticket', 2, 3);

REVERT;
```

**a) `usuario_admin`**

- **Resultado esperado:** el INSERT se realiza correctamente.
- **Resultado obtenido:** (1 fila afectada)
- **Explicación:** la operación puede realizarse porque el usuario pertenece al rol `db_owner`, que le otorga control total sobre la base de datos.

**b) `usuario_lector`**

- **Resultado esperado:** el INSERT es rechazado.
- **Resultado obtenido:**: Mens. 229, Nivel 14, Estado 5, Línea 54
The INSERT permission was denied on the object 'venta', database 'VINOTECA', schema 'dbo'.
- **Explicación:** la operación es rechazada porque el usuario solamente tiene permiso de lectura (`SELECT`) sobre `Venta` y no posee permiso para insertar registros directamente.


### 3.3. INSERT mediante procedimiento almacenado

Se comprueba si el usuario lector puede registrar una venta mediante el procedimiento `sp_RegistrarVenta`, a pesar de no tener permiso de INSERT directo sobre la tabla `Venta`.

```sql
EXECUTE AS USER = 'usuario_lector';

EXEC dbo.sp_RegistrarVenta 2, 3, 4, 2, 90000.00;

REVERT;

-- Se verifica el registro desde el contexto original.
SELECT *
FROM Venta
WHERE id_cliente = 2;
```

- **Resultado esperado:** el procedimiento se ejecuta correctamente y registra la venta.
- **Explicación:** el usuario lector no tiene permiso de INSERT directamente sobre `Venta`, pero sí tiene permiso `EXECUTE` sobre el procedimiento almacenado. La operación puede realizarse mediante el **encadenamiento de propiedad** (*ownership chaining*), siempre que el procedimiento y los objetos a los que accede tengan el mismo propietario efectivo y no se interrumpa dicha cadena. De esta manera, el usuario puede realizar la operación autorizada sin recibir permiso directo de escritura sobre la tabla.


## 4. Permisos a nivel de roles

En este escenario se crea un rol con permiso de lectura sobre la tabla `vino`. Luego se asigna ese rol a uno de los dos usuarios para comparar el acceso de ambos.

### 4.1. Creación de usuarios, rol y asignación

| Usuario | Asignación | Acceso esperado a `vino` |
|---|---|---|
| `usuario_con_rol` | Miembro de `rol_consulta_productos` | Puede consultar la tabla. |
| `usuario_sin_rol` | No pertenece a `rol_consulta_productos` y no tiene permisos explícitos sobre `vino` | No puede consultar la tabla. |

Los comandos principales utilizados son:

```sql
CREATE ROLE rol_consulta_productos;

GRANT SELECT ON dbo.vino TO rol_consulta_productos;

ALTER ROLE rol_consulta_productos ADD MEMBER usuario_con_rol;
```

El rol concede únicamente el permiso `SELECT` sobre la tabla `vino`. Solamente `usuario_con_rol` se incorpora a este rol. `usuario_sin_rol` no pertenece a ese rol ni posee permisos explícitos de lectura sobre la tabla. Como todo usuario de una base de datos, igualmente pertenece al rol integrado `public`, pero este no recibe el permiso `SELECT` sobre `vino` en este escenario.

**Resultado obtenido:** Los comandos se han completado correctamente.

### 4.2. Verificación del comportamiento de ambos usuarios

Se ejecuta una consulta sobre `vino` utilizando primero el usuario que pertenece al rol y luego el que no pertenece.

```sql
-- Prueba con el usuario que tiene el rol
EXECUTE AS USER = 'usuario_con_rol';
SELECT * FROM vino;
REVERT;

-- Prueba con el usuario que no tiene el rol
EXECUTE AS USER = 'usuario_sin_rol';
SELECT * FROM vino;
REVERT;
```

**a) `usuario_con_rol`**

- **Resultado esperado:** la consulta se ejecuta correctamente.
- **Resultado obtenido:** Los comandos se han completado correctamente.
- **Explicación:** el usuario puede consultar la tabla porque pertenece a `rol_consulta_productos`, al que se le concedió el permiso `SELECT` sobre `vino`.

**b) `usuario_sin_rol`**

- **Resultado esperado:** la consulta es rechazada.
- **Resultado obtenido:** ERROR 229, The SELECT permission was denied on the object 'vino', database 'VINOTECA', schema 'dbo'.
- **Explicación:** el usuario no pertenece al rol que otorga permisos de lectura sobre `vino` y tampoco tiene un permiso individual que lo autorice a realizar esa consulta.


## 5. Resumen de las pruebas

| N.º | Prueba | Usuario | Resultado esperado |
|---:|---|---|---|---|---:|
| 1 | Verificación del modo de autenticación | — | `0` (modo mixto) | 
| 2 | INSERT directo en `Venta` | `usuario_admin` | Operación exitosa | 
| 4 | Ejecución de `sp_RegistrarVenta` | `usuario_lector` | Operación exitosa |  
| 5 | SELECT sobre `vino` | `usuario_con_rol` | Consulta exitosa | 
| 6 | SELECT sobre `vino` | `usuario_sin_rol` | Acceso denegado | 

## 6. Conclusiones

A partir de las pruebas realizadas, se comprobó que SQL Server permite administrar el acceso a la información mediante permisos individuales y roles.

En el primer escenario, se verificó que el usuario administrador puede realizar operaciones de escritura, mientras que el usuario lector tiene restringida dicha posibilidad. Sin embargo, este último pudo registrar una venta mediante el procedimiento almacenado autorizado, demostrando que es posible permitir operaciones específicas sin conceder acceso directo a las tablas.

En el segundo escenario, se comprobó que los roles permiten agrupar permisos y asignarlos a diferentes usuarios. El usuario perteneciente a `rol_consulta_productos` pudo consultar la tabla `vino`, mientras que el usuario sin dicha asignación recibió un error de acceso denegado.

En conclusión, la implementación permitió aplicar el principio de mínimo privilegio, restringiendo las operaciones de cada usuario según sus responsabilidades y facilitando la administración de la seguridad mediante roles.

---

