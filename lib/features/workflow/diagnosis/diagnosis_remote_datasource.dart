import 'package:dio/dio.dart';
import 'diagnosis_template_model.dart';

abstract class DiagnosisRemoteDataSource {
  Future<List<DiagnosisTemplateModel>> listTemplates();
  Future<DiagnosisTemplateModel> getLatestTemplate();

  Future<DiagnosisTemplateModel> getTemplateById(String id);
  Future<Map<String, dynamic>?> getReportBySessionId(String sessionId);
  Future<DiagnosisTemplateModel> createTemplate(Map<String, dynamic> data);
  Future<DiagnosisTemplateModel> updateTemplate(String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> submitDiagnosis(
    String sessionId,
    String templateId,
    Map<String, String> responses,
  );
  Future<void> deleteTemplate(String id);
  Future<Map<String, dynamic>?> getEnterprisePerformance(String enterpriseId);
}

class DiagnosisRemoteDataSourceImpl implements DiagnosisRemoteDataSource {
  final Dio dio;

  DiagnosisRemoteDataSourceImpl({required this.dio});

  @override
  Future<DiagnosisTemplateModel> getLatestTemplate() async {
    final response = await dio.get('diagnosis/template/latest');
    
    if (response.data['success'] == true) {
      return DiagnosisTemplateModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch latest template');
    }
  }

  @override
  Future<DiagnosisTemplateModel> getTemplateById(String id) async {
    final response = await dio.get('diagnosis/templates/$id');
    
    if (response.data['success'] == true) {
      return DiagnosisTemplateModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch template');
    }
  }

  @override
  Future<List<DiagnosisTemplateModel>> listTemplates() async {
    final response = await dio.get('diagnosis/templates');
    if (response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((json) => DiagnosisTemplateModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to list templates');
    }
  }

  @override
  Future<DiagnosisTemplateModel> createTemplate(Map<String, dynamic> data) async {
    final response = await dio.post('diagnosis/templates', data: data);
    if (response.data['success'] == true) {
      return DiagnosisTemplateModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create template');
    }
  }

  @override
  Future<DiagnosisTemplateModel> updateTemplate(String id, Map<String, dynamic> data) async {
    final response = await dio.put('diagnosis/templates/$id', data: data);
    if (response.data['success'] == true) {
      return DiagnosisTemplateModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to update template');
    }
  }

  @override
  Future<Map<String, dynamic>?> getReportBySessionId(String sessionId) async {
    try {
      final response = await dio.get('diagnosis/reports/session/$sessionId');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      // A 404 means no report exists yet — that's fine, not an error
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> submitDiagnosis(
    String sessionId,
    String templateId,
    Map<String, String> responses,
  ) async {
    final response = await dio.post('diagnosis/reports', data: {
      'session_id': sessionId,
      'template_id': templateId,
      'responses': responses,
    });

    if (response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Failed to submit diagnosis');
    }
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final response = await dio.delete('diagnosis/templates/$id');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete template');
    }
  }

  @override
  Future<Map<String, dynamic>?> getEnterprisePerformance(String enterpriseId) async {
    try {
      final response = await dio.get('diagnosis/enterprise/$enterpriseId/performance');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Return null only if specifically not found/no reports
      }
      rethrow; // Re-throw other errors (500, connectivity) so UI shows Error state
    } catch (e) {
      rethrow;
    }
  }
}
