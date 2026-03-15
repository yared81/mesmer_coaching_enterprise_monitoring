const { EnterpriseDocument, Enterprise, CoachingSession, User } = require('../models');

class DocumentController {
  
  // POST /api/v1/documents/upload
  uploadDocument = async (req, res, next) => {
    try {
      const { enterprise_id, session_id, file_name, file_url, file_type, document_type } = req.body;
      
      // Note: In a real app, file integration (like S3 upload) happens via Multer middleware
      // and the S3 URL is passed here. For this hackathon scope, the flutter app will pass 
      // a bas64 string or a mock URL, and we just save the record.
      
      const newDoc = await EnterpriseDocument.create({
        enterprise_id,
        session_id: session_id || null, // Optional
        uploader_id: req.user.userId,
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
