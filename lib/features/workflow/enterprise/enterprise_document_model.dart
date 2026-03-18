import 'enterprise_document_entity.dart';

class EnterpriseDocumentModel extends EnterpriseDocumentEntity {
  const EnterpriseDocumentModel({
    required super.id,
    required super.enterpriseId,
    required super.uploaderId,
    required super.fileName,
    required super.fileUrl,
    required super.uploadedAt,
    super.sessionId,
    super.fileType,
    super.documentType,
    super.uploaderName,
    super.sessionTitle,
  });

  factory EnterpriseDocumentModel.fromJson(Map<String, dynamic> json) {
    return EnterpriseDocumentModel(
      id: json['id'] as String,
      enterpriseId: json['enterprise_id'] as String,
      sessionId: json['session_id'] as String?,
      uploaderId: json['uploader_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String?,
      documentType: json['document_type'] as String? ?? 'evidence',
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      uploaderName: json['uploader']?['name'] as String?,
      sessionTitle: json['session']?['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'enterprise_id': enterpriseId,
      if (sessionId != null) 'session_id': sessionId,
      'uploader_id': uploaderId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'document_type': documentType,
    };
  }
}
