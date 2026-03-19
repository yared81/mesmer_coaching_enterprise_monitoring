const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const { connectDB } = require('./src/config/database');
const models = require('./src/models/index.js'); // Ensure models are loaded before sync

const app = express();
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    // Connect to Database
    await connectDB();

    // 1. Mandatory Headers (Nuclear Option)
    app.use((req, res, next) => {
      res.header('Access-Control-Allow-Origin', '*');
      res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
      
      if (req.method === 'OPTIONS') {
        return res.status(200).send();
      }
      
      console.log(`\n[${new Date().toISOString()}] ${req.method} ${req.url}`);
      next();
    });

    app.use(morgan('dev'));
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));

    // Health Check
    app.get('/health', (req, res) => {
      res.status(200).json({ status: 'UP', message: 'MESMER API is reaching you!' });
    });

    // Routes
    app.use('/api/v1/auth', require('./src/routes/auth.routes'));
    app.use('/api/v1/enterprises', require('./src/routes/enterprise.routes'));
    app.use('/api/v1/iaps', require('./src/routes/iap.routes'));
    app.use('/api/v1/dashboard', require('./src/routes/dashboard.routes'));
    app.use('/api/v1/coaches', require('./src/routes/coach.routes'));
    app.use('/api/v1/sessions', require('./src/routes/session.routes'));
    app.use('/api/v1/diagnosis', require('./src/routes/diagnosis.routes'));
    app.use('/api/v1/documents', require('./src/routes/document.routes'));
    app.use('/api/v1/enterprise-dashboard', require('./src/routes/enterprise_dashboard.routes'));
    app.use('/api/v1/notifications', require('./src/routes/notification.routes'));

    // Error Handler
    app.use((err, req, res, next) => {
      console.error('Error:', err.message);
      res.status(500).json({
        success: false,
        message: err.message || 'Internal Server Error'
      });
    });

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 MESMER Server running on http://0.0.0.0:${PORT}`);
    });
  } catch (error) {
    console.error('💥 Failed to initialize server:', error);
    process.exit(1);
  }
};

startServer();
