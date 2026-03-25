const { EnterpriseDocument, Enterprise, CoachingSession, User } = require('../models');

class DocumentController {
  
  // POST /api/v1/documents/upload
  uploadDocument = async (req, res, next) => {
    try {
      const { enterprise_id, session_id, document_type, file_name: manual_name } = req.body;
      
      let file_url = req.body.file_url;
      let file_name = manual_name || req.body.file_name;
      let file_type = req.body.file_type;

      // If a file was uploaded via Multer
      if (req.file) {
        // Generating a relative URL that the static middleware can serve
        // The middleware serves from 'src/uploads' (which is actually '../../uploads' relative to the middleware)
        // server.js has: app.use('/uploads', express.static(path.join(__dirname, 'src/uploads')));
        // But the middleware saves to: path.join(__dirname, '../../uploads/evidence')
        // Let's make sure the path is correct.
        
        file_url = `/uploads/evidence/${req.file.filename}`;
        file_name = manual_name || req.file.originalname;
        file_type = req.file.mimetype;
      }

      const uploader_id = req.user.id || req.user.userId;

      const newDoc = await EnterpriseDocument.create({
        enterprise_id,
        session_id: session_id || null,
        uploader_id,
        file_name,
        file_url,
        file_type,
        document_type: document_type || 'evidence'
      });

      res.status(201).json({
        success: true,
        data: newDoc
      });
    } catch (error) {
      next(error);
    }
  };

  // GET /api/v1/documents/enterprise/:enterpriseId
  getEnterpriseDocuments = async (req, res, next) => {
    try {
      const documents = await EnterpriseDocument.findAll({
        where: { enterprise_id: req.params.enterpriseId },
        include: [
          { model: User, as: 'uploader', attributes: ['name', 'email'] },
          { model: CoachingSession, as: 'session', attributes: ['title', 'scheduled_date'] }
        ],
        order: [['uploaded_at', 'DESC']]
      });

      res.status(200).json({
        success: true,
        data: documents
      });
    } catch (error) {
      next(error);
    }
  };

  // GET /api/v1/documents/session/:sessionId
  getSessionDocuments = async (req, res, next) => {
    try {
      const documents = await EnterpriseDocument.findAll({
        where: { session_id: req.params.sessionId },
        order: [['uploaded_at', 'DESC']]
      });

      res.status(200).json({
        success: true,
        data: documents
      });
    } catch (error) {
      next(error);
    }
  };

  // DELETE /api/v1/documents/:id
  deleteDocument = async (req, res, next) => {
    try {
      const document = await EnterpriseDocument.findOne({
        where: { id: req.params.id }
      });

      if (!document) {
        return res.status(404).json({ success: false, message: 'Document not found' });
      }

      // Check if user is the uploader or a supervisor
      if (document.uploader_id !== req.user.userId && req.user.role !== 'supervisor') {
        return res.status(403).json({ success: false, message: 'Not authorized to delete this document' });
      }

      await document.destroy();

      res.status(200).json({
        success: true,
        data: {}
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new DocumentController();
