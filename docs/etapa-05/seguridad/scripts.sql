 USE VINOTECA
GO
/* ==========================================
   CONFIGURACIÓN DE SEGURIDAD
   Se verifica que SQL Server esté configurado
   en modo de autenticación mixto, permitiendo
   conexiones mediante Windows y SQL Server.
   ========================================== */
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') AS SoloWindows;

/* ==========================================
   PERMISOS A NIVEL DE USUARIOS
   Se crean dos usuarios con diferentes
   privilegios:
   - Administrador: control total sobre la BD.
   - Lector: permisos de consulta y ejecución
     de un procedimiento almacenado.

   Se comprueba el comportamiento de ambos
   mediante operaciones directas y procedimientos.
   ========================================== */
CREATE LOGIN usuario_admin  WITH PASSWORD = 'Admin123*';
CREATE LOGIN usuario_lector WITH PASSWORD = 'Lector123*';
GO

CREATE USER usuario_admin  FOR LOGIN usuario_admin;
CREATE USER usuario_lector FOR LOGIN usuario_lector;
GO

-- Asignación de permisos:

-- Administrador: control total sobre la base
ALTER ROLE db_owner
ADD MEMBER usuario_admin;
GO
-- Lector: solo SELECT sobre la tabla
GRANT SELECT ON dbo.Venta TO usuario_lector;
GO

-- Permiso de ejecución sobre el procedimiento almacenado
GRANT EXECUTE ON dbo.sp_RegistrarVenta TO usuario_lector;
GO

-- Prueba con INSERT directo, con ambos usuarios
-- Como administrador
EXECUTE AS USER = 'usuario_admin';
INSERT INTO Venta(fecha_hora, monto_total, tipo_comprobante,id_cliente, id_usuario) VALUES (GETDATE(), 15000,'Ticket', 2, 3);  
REVERT;

SELECT *
FROM venta
-- Como lector
EXECUTE AS USER = 'usuario_lector';
INSERT INTO Venta(fecha_hora, monto_total, tipo_comprobante,id_cliente, id_usuario) VALUES (GETDATE(), 15000,'Ticket', 2, 3);    -- debe fallar
REVERT;
-- Resultado:ERROR 229, The INSERT permission was denied on the object 'venta', database 'VINOTECA', schema 'dbo'.

--EXECUTE AS USER: cambia temporalmente al usuario indicado para ejecutar las consultas con sus permisos.
--REVERT: una vez terminadas las operaciones, vuelve al usuario con el que estabas trabajando originalmente.

-- Prueba con el procedimiento almacenado (usuario lector).
EXECUTE AS USER = 'usuario_lector';
EXEC dbo.sp_RegistrarVenta 2, 3, 4, 2, 90000.00;   -- debe funcionar
REVERT;
--compruebo en la tabla de ventas si se registro la venta.
SELECT *  
FROM venta

/* ==========================================
   PERMISOS A NIVEL DE ROLES
   Se crean dos usuarios y un rol que permite
   únicamente consultar la tabla Vino.

   El rol se asigna a uno de los usuarios para
   comprobar la diferencia de acceso entre
   ambos usuarios.
   ========================================== */

CREATE LOGIN usuario_con_rol WITH PASSWORD = 'Rol123*';
CREATE LOGIN usuario_sin_rol WITH PASSWORD = 'Rol456*';
GO

CREATE USER usuario_con_rol FOR LOGIN usuario_con_rol;
CREATE USER usuario_sin_rol FOR LOGIN usuario_sin_rol;
GO

-- Creo el rol con permiso de solo lectura
CREATE ROLE rol_consulta_productos;
GRANT SELECT ON dbo.vino TO rol_consulta_productos;   
GO

--Asignacion de rol a un solo usuario
ALTER ROLE rol_consulta_productos ADD MEMBER usuario_con_rol;
GO

EXECUTE AS USER = 'usuario_con_rol';
SELECT * FROM vino;     
REVERT;

EXECUTE AS USER = 'usuario_sin_rol';
SELECT * FROM vino;    
REVERT;
-- RESULTADO: ERROR 229, The SELECT permission was denied on the object 'vino', database 'VINOTECA', schema 'dbo'.

-- Verifico que el usuario con el rol no pueda modificar la tabla.
EXECUTE AS USER = 'usuario_con_rol';

INSERT INTO vino (nombre)
VALUES ('Vino de prueba'); -- Debe fallar

REVERT;