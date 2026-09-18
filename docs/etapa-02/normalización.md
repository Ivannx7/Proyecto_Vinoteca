# Normalización
Las Formas Normales son reglas de diseño de bases de datos relacionales para evitar la redundancia y garantizar la integridad de los datos.

## Primera Forma Normal (1FN) – Atomicidad:
Regla: Cada celda debe contener un valor único, cada columna debe contener valores atómicos (indivisibles) y no debe haber grupos de datos repetidos o listas dentro de un solo campo.
Objetivo: Evitar guardar múltiples valores en una misma celda (por ejemplo, guardar "Rojo, Azul, Verde" en la columna Color). Cada fila/columna debe tener un único valor. Esta forma normal garantiza que cada dato pueda ser manipulado de forma independiente

## Segunda Forma Normal (2FN) – Dependencia Funcional Completa:
Regla: Estar en 1FN y que todos los atributos que no son clave primaria dependan de la clave primaria completa, no solo de una parte de ella. Las dependencias parciales son problemáticas porque introducen redundancia.
Objetivo: Aplica principalmente cuando la clave primaria es compuesta (formada por 2 o más columnas). Si un campo depende solo de una parte de la clave, debe mover a una nueva tabla.

## Tercera Forma Normal (3FN) – Sin Dependencias Transitivas:
Regla: Estar en 2FN y asegurar que ningún atributo no clave dependa de otro atributo no clave. Todos los campos deben depender única y directamente de la clave primaria.
Objetivo: Eliminar dependencias indirectas. Por ejemplo, si en una tabla Empleado guardas ID_Empleado, ID_Departamento y Nombre_Departamento, el nombre depende del departamento y no directamente del empleado; por lo que Departamento debe ir a su propia tabla.
