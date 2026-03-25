const { ConsentRecord, User, Enterprise } = require('../models');

// POST /api/v1/consent
const createConsent = async (req, res) => {
  try {
    const {
      enterprise_id,
      method,
      is_consented,
      safeguarding_acknowledged,
      notes,
    } = req.body;

    if (!enterprise_id || is_consented === undefined) {
      return res.status(400).json({ success: false, message: 'enterprise_id and is_consented are required.' });
    }

    if (!is_consented) {
      return res.status(400).json({ success: false, message: 'Enterprise owner did not give consent. Cannot proceed.' });
    }

    // Check if consent already recorded for this enterprise
    const existing = await ConsentRecord.findOne({ where: { enterprise_id } });
    if (existing) {
      return res.status(409).json({ success: false, message: 'Consent already recorded for this enterprise.' });
    }

    const record = await ConsentRecord.create({
      enterprise_id,
      recorded_by: req.user.id,
      method: method || 'checkbox',
      is_consented,
      safeguarding_acknowledged: safeguarding_acknowledged || false,
      signed_at: new Date(),
      notes,
    });

    return res.status(201).json({ success: true, data: record });
  } catch (error) {
    console.error('Create consent error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/consent/:enterprise_id
const getConsentByEnterprise = async (req, res) => {
  try {
    const { enterprise_id } = req.params;

    const record = await ConsentRecord.findOne({
      where: { enterprise_id },
      include: [
        { model: User, as: 'recorder', attributes: ['id', 'name', 'email'] }
      ]
    });

    if (!record) {
      return res.status(404).json({ success: false, data: null, message: 'No consent record found.' });
    }

    return res.status(200).json({ success: true, data: record });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/consent  (list all, for admin/supervisor)
const listConsents = async (req, res) => {
  try {
    const records = await ConsentRecord.findAll({
      include: [
        { model: Enterprise, as: 'enterprise', attributes: ['id', 'name'] },
        { model: User, as: 'recorder', attributes: ['id', 'name'] }
      ],
      order: [['created_at', 'DESC']],
    });

    return res.status(200).json({ success: true, data: records });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { createConsent, getConsentByEnterprise, listConsents };
