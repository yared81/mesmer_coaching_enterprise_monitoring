const express = require('express');
const router = express.Router();
const documentController = require('../controllers/document.controller');
const { protect } = require('../middleware/auth.middleware');

// In a real production system, use multer here to process multipart/form-data
// const multer = require('multer');
// const upload = multer({ dest: 'uploads/' });

const { upload } = require('../middleware/upload.middleware');

router.use(protect);

// Upload a document
router.post('/upload', upload.single('file'), documentController.uploadDocument);

// Get all documents for an enterprise
router.get('/enterprise/:enterpriseId', documentController.getEnterpriseDocuments);

// Get documents for a specific session
router.get('/session/:sessionId', documentController.getSessionDocuments);

// Delete a document
router.delete('/:id', documentController.deleteDocument);

module.exports = router;
