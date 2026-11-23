// SELMAG - Capa de negocio: API REST con Node.js + Express
const express = require('express');
const pool = require('./db');

// No hace falta CORS: Nginx sirve el front y la API desde el mismo dominio.
const app = express();
app.use(express.json());

const SELECT_PRODUCTO = `
  SELECT p.id, p.sku, p.nombre, p.descripcion, p.precio::float AS precio,
         p.precio_anterior::float AS precio_anterior, p.stock, p.a_pedido_dias,
         p.mas_vendido, c.nombre AS categoria, c.slug AS categoria_slug, m.nombre AS marca
  FROM productos p
  JOIN categorias c ON c.id = p.categoria_id
  JOIN marcas m ON m.id = p.marca_id`;

// Estado del servicio: prueba que la API llega a la base de datos
app.get('/api/health', async (req, res) => {
  try {
    const r = await pool.query('SELECT version() AS version, NOW() AS hora');
    res.json({ api: 'ok', db: 'ok', postgres: r.rows[0].version.split(' on ')[0], hora: r.rows[0].hora });
  } catch (err) {
    res.status(503).json({ api: 'ok', db: 'error', detalle: err.message });
  }
});

// Lista de categorías con cantidad de productos
app.get('/api/categorias', async (req, res, next) => {
  try {
    const r = await pool.query(`
      SELECT c.id, c.nombre, c.slug, COUNT(p.id)::int AS productos
      FROM categorias c LEFT JOIN productos p ON p.categoria_id = c.id
      GROUP BY c.id ORDER BY c.id`);
    res.json(r.rows);
  } catch (err) { next(err); }
});

// Lista de productos. Filtros opcionales: ?q=tablero&categoria=tableros
app.get('/api/productos', async (req, res, next) => {
  try {
    const filtros = [];
    const valores = [];
    if (req.query.q) {
      valores.push(`%${req.query.q}%`);
      filtros.push(`(p.nombre ILIKE $${valores.length} OR p.sku ILIKE $${valores.length})`);
    }
    if (req.query.categoria) {
      valores.push(req.query.categoria);
      filtros.push(`c.slug = $${valores.length}`);
    }
    const where = filtros.length ? ` WHERE ${filtros.join(' AND ')}` : '';
    const r = await pool.query(`${SELECT_PRODUCTO}${where} ORDER BY p.mas_vendido DESC, p.id`, valores);
    res.json(r.rows);
  } catch (err) { next(err); }
});

// Detalle de un producto por SKU (usado también por "Pedido rápido por código")
app.get('/api/productos/:sku', async (req, res, next) => {
  try {
    const r = await pool.query(`${SELECT_PRODUCTO} WHERE p.sku = $1`, [req.params.sku.toUpperCase()]);
    if (!r.rows.length) return res.status(404).json({ error: 'Producto no encontrado' });
    res.json(r.rows[0]);
  } catch (err) { next(err); }
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`SELMAG API escuchando en el puerto ${PORT}`));
