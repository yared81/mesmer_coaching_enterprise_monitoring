const express = require('express');
const router = express.Router();
const trainingController = require('../controllers/training_session.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

router.get('/', authorize('super_admin', 'admin', 'trainer', 'regional_coordinator'), trainingController.getSessions);
router.post('/', authorize('super_admin', 'admin', 'trainer', 'regional_coordinator'), trainingController.createSession);
router.get('/:id', authorize('super_admin', 'admin', 'trainer', 'regional_coordinator'), trainingController.getSessionById);
router.put('/:id', authorize('super_admin', 'admin', 'trainer', 'regional_coordinator'), trainingController.updateSession);
router.delete('/:id', authorize('super_admin', 'admin', 'trainer', 'regional_coordinator'), trainingController.deleteSession);

module.exports = router;
