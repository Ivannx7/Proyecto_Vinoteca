# 🍷 Vinoteca

Proyecto académico grupal desarrollado para la materia **Base de Datos I**, correspondiente al diseño e implementación de una base de datos relacional para un e-commerce de venta de vinos.

El proyecto utiliza **Microsoft SQL Server** como motor de base de datos y **SQL Server Management Studio (SSMS)** como herramienta de administración y desarrollo. Comprende todas las etapas de construcción de una base de datos, desde el relevamiento de requerimientos hasta la implementación de mecanismos de seguridad, auditoría y optimización.

## 📌 Descripción del proyecto

Vinoteca es el modelo de datos de un sistema de venta online de vinos que permite gestionar el catálogo de productos, organizados por categoría y bodega, los clientes, los usuarios internos con distintos roles, las ventas con sus respectivos detalles, los medios de pago y el historial de variación de precios.

El desarrollo contempla el modelado entidad-relación, la transformación al modelo relacional, la normalización de las tablas y la implementación de mecanismos que garantizan la integridad y consistencia de la información.

## 🎯 Objetivos del proyecto

Diseñar e implementar una base de datos relacional normalizada que dé soporte a las principales operaciones de una vinoteca online.

Entre los objetivos específicos se encuentran:

- Representar correctamente las entidades y relaciones del negocio.
- Aplicar reglas de integridad referencial mediante claves primarias, foráneas y restricciones.
- Registrar el historial de precios de los productos para mantener su trazabilidad.
- Administrar usuarios internos con distintos roles y permisos.
- Gestionar ventas, detalles y múltiples medios de pago.
- Implementar consultas, vistas, procedimientos almacenados, funciones, transacciones y triggers.
- Incorporar mecanismos de seguridad, auditoría y optimización.

## 🛠️ Tecnologías utilizadas

| Tecnología | Utilización |
|---|---|
| Microsoft SQL Server | Motor de base de datos |
| SQL Server Management Studio (SSMS) | Administración y desarrollo |
| Transact-SQL (T-SQL) | Lenguaje para consultas y operaciones sobre la base de datos |
| Git / GitHub | Control de versiones y almacenamiento del proyecto |
| Markdown | Documentación de las etapas e investigaciones |

## 🗂️ Estructura del repositorio

El repositorio se organiza principalmente en dos directorios: `docs/`, destinado a la documentación de las etapas, y `sql/`, que contiene los scripts SQL utilizados para la implementación y consulta de la base de datos.

```text
Proyecto_Vinoteca/
│
├── docs/
│   ├── etapa-01/
│   │   └── equipo41_etapa_1.md
│   │
│   ├── etapa-02/
│   │   ├── DER/
│   │       └── erdplus(1).png
│   │   ├── Modelo Relacional/
│   │       └── erdVINOTECA3.png
│   │   ├── Primeros Planteos/
│   │       └── der_primer_planteo.png
│   │       └── estructura-inicial.md
│   │   ├── Proceso de Normalización/
│   │       └── erdplus.png
│   │
│   ├── etapa-03/
│   │   ├── implementacion.md
│   │   ├── pruebas-validacion.md
│   │   └── restricciones-integridad.md
│   │
│   ├── etapa-04/
│   │   ├── casos-uso.md
│   │   ├── comprobante-venta.md
│   │   ├── consulta-avanzada.md
│   │   └── informe-ventas.md
│   │
│   ├── etapa-05/
│   │    ├── funciones/
│   │       └── caso-funciones1.png
│   │       └── caso-funciones2.png
│   │       └── caso-funciones3.png
│   │       └── caso-funciones4.png
│   │       └── caso-funciones5.png
│   │       └── investigacion.md
│   │       └── scripts.sql
│   │    ├── manejo-transacciones/
│   │       └──sql/
│   │             └── procedimiento_almacenado.sql
│   │             └── prueba_venta_correcta.sql
│   │       └── prueba_venta_incorrecta.sql
│   │       └── caso_concreto_aplicado.md
│   │       └── definicion_y_objetivo.md
│   │       └── implementacion_sql_server_express.md
│   │    ├── optimizacion/
│   │       └── OptimizacionEtapaV.md
│   │       └── OptimizacionEtapaV.sql
│   │    ├── procedimientos/
│   │       └── investigacion.md
│   │       └── scripts.sql
│   │    ├── seguridad/
│   │       └── investigacion.md
│   │       └── scripts.sql
│   │    └── triggers_auditoria/
│   │       └── evidencia.png
│   │       └── investigacion.md
│   │       └── scripts.sql
│   │
├── sql/
│   ├── consultas/
│   │   ├── comprobante_venta.sql
│   │   ├── consulta_avanzada.sql
│   │   └── informe_ventas.sql
│   │
│   ├── ddl/
│   │   ├── 01_ddl_vinoteca.sql
│   │   ├── reglas_borrado_modificacion.sql
│   │   ├── SQLQuery-tablascatalogo1.sql
│   │   └── SQLQuery-updateCliente.sql        
│   │
│   └── dml/
│       └── dml_vinoteca.sql
│
└── README.md
```

### 📂 Organización de los directorios

**`docs/` – Documentación**

Contiene los documentos, investigaciones, diagramas, modelos y casos de prueba correspondientes a cada etapa del proyecto.

**`sql/` – Scripts SQL**

Contiene los archivos ejecutables para la creación y modificación de la estructura de la base de datos, la carga de información y la realización de consultas.

**`README.md` – Guía principal**

Presenta el proyecto y permite localizar rápidamente sus principales documentos y entregables.

## 📚 Etapas del proyecto

El desarrollo se encuentra dividido en cinco etapas, cada una orientada a resolver una pregunta fundamental dentro del proceso de diseño e implementación de una base de datos.

### Etapa 01 – Relevamiento de requerimientos

**Pregunta principal: ¿Qué necesita el negocio?**

Se identifican las necesidades del sistema, los requerimientos funcionales y las reglas de negocio que determinan cómo debe comportarse la vinoteca online.

**Entregables:** relevamiento de requerimientos y definición de reglas de negocio.

[📁 Acceder a la Etapa 01](docs/etapa-01/)

### Etapa 02 – Diseño de la base de datos

**Pregunta principal: ¿Cómo representamos la información?**

Se desarrolla el diseño conceptual y lógico de la base de datos, identificando entidades, atributos, relaciones y restricciones.

Se realiza la transformación del diagrama entidad-relación (DER) al modelo relacional y se aplica el proceso de normalización hasta alcanzar la Tercera Forma Normal (3FN).

**Entregables:**
- Diagrama entidad-relación (DER).
- Modelo relacional.
- Primeros planteos del diseño.
- Proceso de normalización.

[📁 Acceder a la Etapa 02](docs/etapa-02/)

### Etapa 03 – Implementación de la base de datos

**Pregunta principal: ¿Cómo construimos la base de datos?**

Se implementa el diseño lógico utilizando SQL Server, mediante sentencias DDL y DML. También se establecen las restricciones necesarias para mantener la integridad y consistencia de los datos.

**Entregables:**
- Implementación de la estructura de la base de datos.
- Carga de datos.
- Restricciones de integridad.
- Pruebas y validaciones.

**Scripts principales:** `sql/ddl/` y `sql/dml/`.

[📁 Acceder a la Etapa 03](docs/etapa-03/)

### Etapa 04 – Consultas y casos de uso

**Pregunta principal: ¿Cómo obtenemos información?**

Se desarrollan consultas SQL orientadas a resolver diferentes necesidades del negocio, permitiendo recuperar, procesar y presentar información relevante de la vinoteca.

Se implementan casos de uso que permiten representar situaciones concretas del funcionamiento del sistema.

**Entregables:**
- Casos de uso.
- Comprobante de venta.
- Consulta avanzada.
- Informe de ventas.

**Scripts principales:** `sql/consultas/`.

[📁 Acceder a la Etapa 04](docs/etapa-04/)

### Etapa 05 – Robustez y administración de la base de datos

**Pregunta principal: ¿Cómo hacemos la solución más robusta?**

Se incorporan mecanismos avanzados para mejorar la administración, consistencia, seguridad y rendimiento de la base de datos.

Esta etapa comprende:

- **Funciones almacenadas:** encapsulación de cálculos y operaciones reutilizables.
- **Procedimientos almacenados:** ejecución de operaciones y lógica de negocio.
- **Manejo de transacciones:** control de operaciones mediante mecanismos de confirmación y reversión.
- **Triggers de auditoría:** registro y seguimiento de modificaciones realizadas sobre los datos.
- **Optimización:** mejoras orientadas al rendimiento de las operaciones y consultas.
- **Seguridad:** configuración de usuarios, permisos y mecanismos de protección de la información.

Cada temática cuenta con sus respectivos scripts SQL, documentación de investigación y casos de prueba.

[📁 Acceder a la Etapa 05](docs/etapa-05/)

## ⚙️ Ejecución del proyecto

Para trabajar con la base de datos se requiere tener instalado:

- Microsoft SQL Server.
- SQL Server Management Studio (SSMS).

**Pasos generales para la implementación:**

1. Abrir SQL Server Management Studio y conectarse a una instancia del motor SQL Server.
2. Ejecutar el script principal `sql/ddl/01_ddl_vinoteca.sql` para crear la estructura de la base de datos.
3. Ejecutar los scripts DDL complementarios cuando corresponda.
4. Ejecutar `sql/dml/dml_vinoteca.sql` para cargar los datos de prueba.
5. Ejecutar los archivos de `sql/consultas/` para obtener los informes y resultados correspondientes.
6. Para trabajar con los desarrollos de la Etapa 05, acceder a la carpeta de cada temática y ejecutar sus scripts según los requisitos y dependencias correspondientes.

**Nota:** Se recomienda utilizar una base de datos de prueba y verificar que se encuentre seleccionada la base de datos `VINOTECA` antes de ejecutar los scripts correspondientes.

## 👥 Modalidad de trabajo

Proyecto académico desarrollado de manera grupal, mediante la distribución de tareas, investigación, implementación y documentación de las distintas etapas.

El repositorio reúne el trabajo realizado durante todo el desarrollo de la materia, permitiendo consultar tanto los resultados obtenidos como el proceso seguido para alcanzarlos.

---

**Vinoteca – Base de Datos I**  
*Diseño, implementación y administración de una base de datos relacional.*