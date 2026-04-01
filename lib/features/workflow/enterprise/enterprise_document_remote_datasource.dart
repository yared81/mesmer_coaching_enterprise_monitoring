import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'enterprise_document_model.dart';

class EnterpriseDocumentRemoteDataSource {
  final Dio _dio;
  
  // Local fallback storage for debugging
  static final List<EnterpriseDocumentModel> _localDocs = [];

  EnterpriseDocumentRemoteDataSource(this._dio);

  Future<EnterpriseDocumentModel> uploadDocument({
    required String enterpriseId,
    String? sessionId,
    required String filePath,
    String? fileName,
    String? documentType,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'enterprise_id': enterpriseId,
        'session_id': sessionId,
        'document_type': documentType ?? 'evidence',
        'file_name': fileName ?? filePath.split('/').last,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/documents/upload',
        data: formData,
        onSendProgress: onProgress,
      );

      return EnterpriseDocumentModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
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
