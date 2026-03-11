const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const { connectDB } = require('./src/config/database');

const app = express();
const PORT = process.env.PORT || 3000;

// Connect to Database
connectDB();

// Basic Middleware
app.use(cors()); // Standard "allow all" for dev
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

// Routes
app.use('/api/v1/auth', require('./src/routes/auth.routes'));

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: err.message || 'Internal Server Error'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 MESMER Server running on http://localhost:${PORT}`);
});
