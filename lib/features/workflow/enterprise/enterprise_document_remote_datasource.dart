import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'enterprise_document_model.dart';

class EnterpriseDocumentRemoteDataSource {
  final Dio _dio;
  
  // Local fallback storage for debugging
  static final List<EnterpriseDocumentModel> _localDocs = [];

  EnterpriseDocumentRemoteDataSource(this._dio);

  Future<EnterpriseDocumentModel> uploadDocument(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('${ApiConstants.baseUrl}/documents/upload', data: data);
      final doc = EnterpriseDocumentModel.fromJson(response.data['data']);
      _localDocs.add(doc);
      return doc;
    } catch (e) {
      // Fallback for debugging
      final newDoc = EnterpriseDocumentModel(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        enterpriseId: data['enterprise_id'],
        sessionId: data['session_id'],
        uploaderId: 'current-user',
        fileName: data['file_name'],
        fileUrl: data['file_url'],
        fileType: data['file_type'],
        documentType: data['document_type'] ?? 'evidence',
        uploadedAt: DateTime.now(),
      );
      _localDocs.add(newDoc);
      return newDoc;
    }
  }

  Future<List<EnterpriseDocumentModel>> getEnterpriseDocuments(String enterpriseId) async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/documents/enterprise/$enterpriseId');
      final list = response.data['data'] as List;
      return list.map((json) => EnterpriseDocumentModel.fromJson(json)).toList();
    } catch (e) {
      return _localDocs.where((d) => d.enterpriseId == enterpriseId).toList();
    }
  }

  Future<List<EnterpriseDocumentModel>> getSessionDocuments(String sessionId) async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/documents/session/$sessionId');
      final list = response.data['data'] as List;
      return list.map((json) => EnterpriseDocumentModel.fromJson(json)).toList();
    } catch (e) {
      return _localDocs.where((d) => d.sessionId == sessionId).toList();
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/documents/$id');
    } catch (e) {
      _localDocs.removeWhere((d) => d.id == id);
    }
  }
}
