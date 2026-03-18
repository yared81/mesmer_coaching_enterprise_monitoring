// Entity representing an uploaded document or evidence picture

class EnterpriseDocumentEntity {
  const EnterpriseDocumentEntity({
    required this.id,
    required this.enterpriseId,
    required this.uploaderId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedAt,
    this.sessionId,
    this.fileType,
    this.documentType = 'evidence',
    this.uploaderName,
    this.sessionTitle,
  });

  final String id;
  final String enterpriseId;
  final String? sessionId;
  final String uploaderId;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final String documentType;
  final DateTime uploadedAt;
  
  // Optional expanded fields from backend includes
  final String? uploaderName;
  final String? sessionTitle;
}
