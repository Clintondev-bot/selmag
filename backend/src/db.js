// Conexión a PostgreSQL. Las variables PGHOST, PGUSER, PGPASSWORD, PGDATABASE
// y PGPORT vienen de docker-compose.yml (y este las toma del archivo .env).
const { Pool } = require('pg');

const pool = new Pool({ max: 10 });

module.exports = pool;
