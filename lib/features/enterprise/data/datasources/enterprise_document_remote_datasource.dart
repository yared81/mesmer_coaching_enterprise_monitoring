import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/enterprise_document_model.dart';

class EnterpriseDocumentRemoteDataSource {
  final Dio _dio;

  EnterpriseDocumentRemoteDataSource(this._dio);

  Future<EnterpriseDocumentModel> uploadDocument(Map<String, dynamic> data) async {
    final response = await _dio.post('${ApiConstants.baseUrl}/documents/upload', data: data);
    return EnterpriseDocumentModel.fromJson(response.data['data']);
  }

  Future<List<EnterpriseDocumentModel>> getEnterpriseDocuments(String enterpriseId) async {
    final response = await _dio.get('${ApiConstants.baseUrl}/documents/enterprise/$enterpriseId');
    final list = response.data['data'] as List;
    return list.map((json) => EnterpriseDocumentModel.fromJson(json)).toList();
  }

  Future<List<EnterpriseDocumentModel>> getSessionDocuments(String sessionId) async {
    final response = await _dio.get('${ApiConstants.baseUrl}/documents/session/$sessionId');
    final list = response.data['data'] as List;
    return list.map((json) => EnterpriseDocumentModel.fromJson(json)).toList();
  }

  Future<void> deleteDocument(String id) async {
    await _dio.delete('${ApiConstants.baseUrl}/documents/$id');
  }
}
