# Normalización
Las Formas Normales son reglas de diseño de bases de datos relacionales para evitar la redundancia y garantizar la integridad de los datos.

## Primera Forma Normal (1FN)-Atomicidad
Regla: cada celda debe contener un valor único, cada columna debe contener valores atómicos (indivisibles) y no debe haber grupos de datos repetidos o listas dentro de un solo campo.
Objetivo: evitar guardar múltiples valores en una misma celda (ejemplo, guardar "rojo, azul, verde" en la columna color). Cada fila/columna debe tener un único valor. Esta forma normal garantiza que cada dato pueda ser manipulado de forma independiente.

## Segunda Forma Normal (2FN)-Dependencia Funcional Completa
Regla: estar en 1FN y que todos los atributos que no son clave primaria dependan de la clave primaria completa, no solo de parte de ella. Las dependencias parciales son problemáticas porque introducen redundancia.
Objetivos: aplica principalmente cuando la clave primaria es compuesta (formada por 2 o mas columnas). si un campo depende solo de una parte de la clave, debe mover a una nueva tabla.

## Tercera Forma Normal (3FN)-Sin Dependencias Transitivas
Regla: estar en 2FN y asegurar que ningún atributo no clave dependa de otro atributo no clave. Todos los campos deben depender única y directamente de la clave primaria.
Objetivos: eliminar dependencias indirectas. Ejemplo, si en una tabla Empleado guardas Id_empleado, id_departamento y nombre_departamento, el nombre depende del departamento y no directamente del empleado, por lo que departamento debe ir a su propia tabla.
