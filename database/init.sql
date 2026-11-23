-- SELMAG - Capa de datos (PostgreSQL 16)
-- Se ejecuta automáticamente la primera vez que se crea el contenedor "db".

CREATE TABLE categorias (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(80) NOT NULL UNIQUE,
  slug    VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE marcas (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE productos (
  id              SERIAL PRIMARY KEY,
  sku             VARCHAR(30) NOT NULL UNIQUE,
  nombre          VARCHAR(160) NOT NULL,
  descripcion     TEXT,
  categoria_id    INT NOT NULL REFERENCES categorias(id),
  marca_id        INT NOT NULL REFERENCES marcas(id),
  precio          NUMERIC(10,2) NOT NULL CHECK (precio > 0),   -- precio web inc. IGV
  precio_anterior NUMERIC(10,2),
  stock           INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
  a_pedido_dias   INT,                                         -- NULL = entrega inmediata
  mas_vendido     BOOLEAN NOT NULL DEFAULT FALSE,
  creado_en       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE clientes (
  id            SERIAL PRIMARY KEY,
  nombre        VARCHAR(120) NOT NULL,
  email         VARCHAR(120) NOT NULL UNIQUE,
  telefono      VARCHAR(20),
  ruc           VARCHAR(11),
  razon_social  VARCHAR(160),
  creado_en     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE pedidos (
  id               SERIAL PRIMARY KEY,
  cliente_id       INT NOT NULL REFERENCES clientes(id),
  metodo_entrega   VARCHAR(20) NOT NULL CHECK (metodo_entrega IN ('LIMA','PROVINCIA','RECOJO')),
  comprobante      VARCHAR(10) NOT NULL CHECK (comprobante IN ('BOLETA','FACTURA')),
  costo_envio      NUMERIC(10,2) NOT NULL DEFAULT 0,
  total            NUMERIC(10,2) NOT NULL,
  estado           VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
  creado_en        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE detalle_pedido (
  pedido_id        INT NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
  producto_id      INT NOT NULL REFERENCES productos(id),
  cantidad         INT NOT NULL CHECK (cantidad > 0),
  precio_unitario  NUMERIC(10,2) NOT NULL,
  descuento_pct    NUMERIC(4,2) NOT NULL DEFAULT 0,   -- 5% desde 5 u., 8% desde 10 u.
  PRIMARY KEY (pedido_id, producto_id)
);

CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_nombre ON productos USING gin (to_tsvector('spanish', nombre));

-- ===== Datos de prueba (tomados de la maqueta E1) =====
INSERT INTO categorias (nombre, slug) VALUES
  ('Tableros eléctricos', 'tableros'),
  ('Interruptores termomagnéticos', 'termomagneticos'),
  ('Interruptores diferenciales', 'diferenciales'),
  ('Contactores y guardamotores', 'contactores'),
  ('Cajas y canalización', 'cajas'),
  ('Iluminación industrial', 'iluminacion');

INSERT INTO marcas (nombre) VALUES
  ('SELMAG Pro'), ('Schneider Electric'), ('ABB'), ('Hager'), ('Legrand'), ('Siemens');

INSERT INTO productos (sku, nombre, descripcion, categoria_id, marca_id, precio, precio_anterior, stock, a_pedido_dias, mas_vendido) VALUES
  ('SEL-TE-12',   'Tablero termomagnético empotrable 12 polos con riel DIN', 'Incluye barras de neutro y tierra.', 1, 1, 189.90, NULL, 60, NULL, TRUE),
  ('SEL-TM-24',   'Tablero metálico adosable 24 polos IP40', 'Gabinete de acero con pintura electrostática, dos filas de 12 polos, barras de neutro y tierra incluidas.', 1, 1, 289.90, 329.00, 40, NULL, TRUE),
  ('SEL-TP-08',   'Tablero termoplástico adosable 8 polos IP65', NULL, 1, 5, 96.50, NULL, 35, NULL, FALSE),
  ('SEL-TM-36T',  'Tablero metálico empotrable 36 polos trifásico', NULL, 1, 1, 459.00, NULL, 15, NULL, FALSE),
  ('SEL-TA-1880', 'Tablero autosoportado 1800x800x400 mm IP55', 'Fabricación propia.', 1, 1, 3890.00, NULL, 0, 7, FALSE),
  ('SEL-ITM-2P32','Interruptor termomagnético 2x32A 10kA', NULL, 2, 2, 42.50, NULL, 200, NULL, TRUE),
  ('SEL-ITM-2P16','Interruptor termomagnético 2x16A 6kA', NULL, 2, 3, 29.90, NULL, 150, NULL, FALSE),
  ('SEL-ITM-2P20','Interruptor termomagnético 2x20A 6kA', NULL, 2, 5, 31.50, NULL, 150, NULL, FALSE),
  ('SEL-ID-2P40', 'Interruptor diferencial 2x40A 30mA', 'Protección contra fugas a tierra.', 3, 4, 128.00, NULL, 80, NULL, TRUE),
  ('SEL-CP-303',  'Caja de pase metálica 300x300x150 mm', NULL, 5, 1, 64.90, NULL, 120, NULL, FALSE);
