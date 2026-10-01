USE vinoteca;

--TABLAS CATALOGO

CREATE TABLE cepa(
  cepa_id INT IDENTITY(1,1) NOT NULL,
  nombre_cepa VARCHAR(50) NOT NULL,
  CONSTRAINT pk_cepa PRIMARY KEY(cepa_id),
  CONSTRAINT uq_cepa_nombre UNIQUE(nombre_cepa)
  )

CREATE TABLE pais(
  pais_id INT IDENTITY(1,1) NOT NULL,
  nombre_pais VARCHAR(50) NOT NULL,
  CONSTRAINT pk_pais PRIMARY KEY(pais_id),
  CONSTRAINT uq_pais_nombre UNIQUE(nombre_pais)
  )
CREATE TABLE categoria(
  categoria_id INT IDENTITY(1,1) NOT NULL,
  nombre_categoria VARCHAR(50) NOT NULL,
  descripcion VARCHAR(150) ,
  CONSTRAINT pk_categoria PRIMARY KEY(categoria_id),
  CONSTRAINT uq_categoria_nombre UNIQUE(nombre_categoria)
  )
CREATE TABLE rol(
  rol_id INT IDENTITY(1,1) NOT NULL,
  nombre_rol VARCHAR(50) NOT NULL,
  descripcion VARCHAR(150), 
  estado BIT NOT NULL CONSTRAINT df_rol_estado DEFAULT 1,
  CONSTRAINT pk_rol PRIMARY KEY(rol_id),
  CONSTRAINT uq_rol_nombre UNIQUE(nombre_rol)
  )

CREATE TABLE metodo_pago(
  metodo_pago_id INT IDENTITY(1,1) NOT NULL,
  nombre_metodo VARCHAR(50) NOT NULL,
  estado BIT NOT NULL CONSTRAINT df_metodo_estado DEFAULT 1,
  CONSTRAINT pk_metodo_pago PRIMARY KEY(metodo_pago_id),
  CONSTRAINT uq_metodo_nombre UNIQUE(nombre_metodo)
  )

CREATE TABLE cliente ( 
 cliente_id INT IDENTITY(1,1) NOT NULL,
 dni VARCHAR(20) NOT NULL, 
 nombre VARCHAR(100) NOT NULL, 
 apellido VARCHAR(100) NOT NULL, 
 fecha_nacimiento DATE NOT NULL, 
 email VARCHAR(150) NOT NULL, 
 CONSTRAINT pk_cliente PRIMARY KEY (cliente_id), 
 CONSTRAINT uq_cliente_dni UNIQUE (dni), 
 CONSTRAINT uq_cliente_email UNIQUE (email) 
 ); 
