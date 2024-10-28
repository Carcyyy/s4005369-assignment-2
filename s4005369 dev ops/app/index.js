const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const app = express();


const port = process.env.PORT || 3001;

// Set up body parser middleware
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

// Set up the view engine
app.set('view engine', 'ejs');

// Health check endpoint
app.get('/health-check', (req, res) => {
  res.json({ info: 'Foo app is alive :-)' });
});

// Home page route
app.get('/', (req, res) => {
  res.render('pages/index');
});

// Static demo data
const static_demo_foos = [
  { name: 'Big Foo', height: '201cm' },
  { name: 'Little Foo', height: '30cm' },
];




const { Pool } = require('pg');


const dbUser = process.env.DB_USERNAME || 'pete';
const dbHost = process.env.DB_HOSTNAME || 'localhost';
const dbName = process.env.DB_NAME || 'foo';
const dbPassword = process.env.DB_PASSWORD || 'devops';
const dbPort = process.env.DB_PORT || 5432;

const pool = new Pool({
  user: dbUser,
  host: dbHost,
  database: dbName,
  password: dbPassword,
  port: dbPort,
});


// Log database connection details for debugging
console.log('Attempting to connect to the database with the following details:');
console.log(`User: ${dbUser}`);
console.log(`Host: ${dbHost}`);
console.log(`Database: ${dbName}`);
console.log(`Port: ${dbPort}`);

// Handle database connection errors
pool.on('error', (err) => {
  console.error('Unexpected error on idle database client', err);
  process.exit(-1);
});

// Endpoint to get list of foos from the database
app.get('/foos', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM foos ORDER BY id ASC');
    res.render('pages/foos', { foos: result.rows });
  } catch (error) {
    console.error('Error executing query:', error);
    res.status(500).send('Database error');
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});
