USE VINOTECA
GO
-- 1. ENTIDADES INDEPENDIENTES / CATÁLOGOS BASE

-- CEPA
CREATE TABLE cepa (
    id_cepa INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT pk_cepa PRIMARY KEY (id_cepa)
);

-- CATEGORIA
CREATE TABLE categoria (
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
);

-- PAIS  [CORREGIDO: reemplaza a "provincia"]
CREATE TABLE pais (
    id_pais INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT pk_pais PRIMARY KEY (id_pais)
);

-- ROL
CREATE TABLE rol (
    id_rol INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    fecha_creacion DATE NOT NULL,
    estado BIT NOT NULL CONSTRAINT df_rol_estado DEFAULT 1, -- [CORREGIDO: agregado, unificado con script de catálogo]
    CONSTRAINT pk_rol PRIMARY KEY (id_rol)
);

-- CLIENTE
CREATE TABLE cliente (
    id_cliente INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NULL,
    telefono VARCHAR(30) NULL,
    correo_electronico VARCHAR(150) NULL,
    fecha_nacimiento DATE NULL,
    es_consumidor_final BIT NOT NULL DEFAULT 1, -- BIT: 1 = TRUE, 0 = FALSE
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
);

-- METODO_PAGO
CREATE TABLE metodo_pago (
    id_metodo_pago INT IDENTITY(1,1) NOT NULL,
    nombre_metodo VARCHAR(50) NOT NULL,
    estado BIT NOT NULL CONSTRAINT df_metodo_estado DEFAULT 1, -- [CORREGIDO: antes VARCHAR(20) DEFAULT 'Activo', unificado con script de catálogo]
    CONSTRAINT pk_metodo_pago PRIMARY KEY (id_metodo_pago)
);

-- 2. ENTIDADES CON DEPENDENCIAS DE PRIMER Y SEGUNDO NIVEL

-- REGION (Depende de PAIS)
CREATE TABLE region (
    id_region INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    id_pais INT NOT NULL,
    CONSTRAINT pk_region PRIMARY KEY (id_region),
    CONSTRAINT fk_region_pais FOREIGN KEY (id_pais)
        REFERENCES pais(id_pais)
);

-- BODEGA (Depende de REGION)
CREATE TABLE bodega (
    id_bodega INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    id_region INT NOT NULL,
    CONSTRAINT pk_bodega PRIMARY KEY (id_bodega),
    CONSTRAINT fk_bodega_region FOREIGN KEY (id_region) 
        REFERENCES region(id_region)
);

-- USUARIO (Depende de ROL)
CREATE TABLE usuario (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(150) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Activo',
    fecha_registro DATETIME NOT NULL,
    ultimo_inicio_sesion DATETIME NULL,
    id_rol INT NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) 
        REFERENCES rol(id_rol),
    CONSTRAINT uq_usuario_correo UNIQUE (correo_electronico)
);

-- VINO (Depende de CATEGORIA y BODEGA)
CREATE TABLE vino (
    id_vino INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    cosecha INT NULL,
    graduacion_alcoholica DECIMAL(4,2) NULL,
    descripcion VARCHAR(255) NULL,
    precio_venta DECIMAL(12,2) NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 0,
    estado VARCHAR(20) NOT NULL DEFAULT 'Activo',
    id_categoria INT NOT NULL,
    id_bodega INT NOT NULL,
    CONSTRAINT pk_vino PRIMARY KEY (id_vino),
    CONSTRAINT fk_vino_categoria FOREIGN KEY (id_categoria) 
        REFERENCES categoria(id_categoria),
    CONSTRAINT fk_vino_bodega FOREIGN KEY (id_bodega) 
        REFERENCES bodega(id_bodega),
    CONSTRAINT chk_vino_precio CHECK (precio_venta >= 0),
    CONSTRAINT chk_vino_stock CHECK (stock_actual >= 0 AND stock_minimo >= 0)
);

-- VINO_CEPA (Relación N:M entre VINO y CEPA) - PK compuesta, sin IDENTITY
CREATE TABLE vino_cepa (
    id_vino INT NOT NULL,
    id_cepa INT NOT NULL,
    CONSTRAINT pk_vino_cepa PRIMARY KEY (id_vino, id_cepa),
    CONSTRAINT fk_vino_cepa_vino FOREIGN KEY (id_vino) 
        REFERENCES vino(id_vino),
    CONSTRAINT fk_vino_cepa_cepa FOREIGN KEY (id_cepa) 
        REFERENCES cepa(id_cepa)
);


-- 3. TRANSACCIONAL Y REGISTROS HISTÓRICOS

-- VENTA (Depende de CLIENTE y USUARIO)
CREATE TABLE venta (
    id_venta INT IDENTITY(1,1) NOT NULL,
    fecha_hora DATETIME NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL,
    tipo_comprobante VARCHAR(20) NOT NULL,
    id_cliente INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT pk_venta PRIMARY KEY (id_venta),
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente) 
        REFERENCES cliente(id_cliente),
    CONSTRAINT fk_venta_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario(id_usuario),
    CONSTRAINT chk_venta_monto CHECK (monto_total >= 0)
);

-- DETALLE_VENTA (Depende de VENTA y VINO)
CREATE TABLE detalle_venta (
    id_detalle_venta INT IDENTITY(1,1) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario_historico DECIMAL(12,2) NOT NULL,
    porcentaje_descuento DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    id_vino INT NOT NULL,
    id_venta INT NOT NULL,
    CONSTRAINT pk_detalle_venta PRIMARY KEY (id_detalle_venta),
    CONSTRAINT fk_detalle_venta_vino FOREIGN KEY (id_vino) 
        REFERENCES vino(id_vino),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (id_venta) 
        REFERENCES venta(id_venta),
    CONSTRAINT uq_detalle_venta_vino UNIQUE (id_venta, id_vino),
    CONSTRAINT chk_detalle_venta_cantidad CHECK (cantidad > 0)
);

-- HISTORIAL_PRECIO (Depende de USUARIO, VINO y opcionalmente DETALLE_VENTA)
CREATE TABLE historial_precio (
    id_historial_precio INT IDENTITY(1,1) NOT NULL,
    fecha_vigencia DATETIME NOT NULL,
    precio_nuevo DECIMAL(12,2) NOT NULL,
    precio_anterior DECIMAL(12,2) NOT NULL,
    id_usuario INT NOT NULL,
    id_vino INT NOT NULL,
    id_detalle_venta INT NULL,
    CONSTRAINT pk_historial_precio PRIMARY KEY (id_historial_precio),
    CONSTRAINT fk_historial_precio_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario(id_usuario),
    CONSTRAINT fk_historial_precio_vino FOREIGN KEY (id_vino) 
        REFERENCES vino(id_vino),
    CONSTRAINT fk_historial_precio_detalle FOREIGN KEY (id_detalle_venta) 
        REFERENCES detalle_venta(id_detalle_venta)
);

-- VENTA_PAGO (Depende de VENTA y METODO_PAGO)
CREATE TABLE venta_pago (
    id_pago INT IDENTITY(1,1) NOT NULL,
    fecha_hora DATETIME NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    id_venta INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    CONSTRAINT pk_venta_pago PRIMARY KEY (id_pago),
    CONSTRAINT fk_venta_pago_venta FOREIGN KEY (id_venta) 
        REFERENCES venta(id_venta),
    CONSTRAINT fk_venta_pago_metodo FOREIGN KEY (id_metodo_pago) 
        REFERENCES metodo_pago(id_metodo_pago),
    CONSTRAINT chk_venta_pago_monto CHECK (monto > 0)
);
