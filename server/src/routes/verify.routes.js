const express = require('express');
const router = express.Router();
const verifyController = require('../controllers/verify.controller');

// Public route to verify graduation certificates
router.get('/:code', verifyController.verifyCertificate);

module.exports = router;
