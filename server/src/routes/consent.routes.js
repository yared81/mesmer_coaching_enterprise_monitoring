const express = require('express');
const router = express.Router();
const { createConsent, getConsentByEnterprise, listConsents } = require('../controllers/consent.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

// All routes require authentication
router.use(authenticate);

// POST /api/v1/consent (enumerator, coach records consent)
router.post('/', authorize(['enumerator', 'coach', 'supervisor', 'admin']), createConsent);

// GET /api/v1/consent (list all — supervisors and admins)
router.get('/', authorize(['supervisor', 'me_officer', 'admin', 'regional_coordinator']), listConsents);

// GET /api/v1/consent/:enterprise_id (check if an enterprise has consent)
router.get('/:enterprise_id', authenticate, getConsentByEnterprise);

module.exports = router;
