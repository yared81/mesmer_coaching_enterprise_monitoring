import 'package:dio/dio.dart';
import '../models/diagnosis_template_model.dart';

abstract class DiagnosisRemoteDataSource {
  Future<List<DiagnosisTemplateModel>> listTemplates();
  Future<DiagnosisTemplateModel> getLatestTemplate();
  Future<Map<String, dynamic>?> getReportBySessionId(String sessionId);
  Future<DiagnosisTemplateModel> createTemplate(Map<String, dynamic> data);
  Future<DiagnosisTemplateModel> updateTemplate(String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> submitDiagnosis({
    required String sessionId,
    required String templateId,
    required Map<String, String> responses,
  });
  Future<void> deleteTemplate(String id);
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
  Future<Map<String, dynamic>> submitDiagnosis({
    required String sessionId,
    required String templateId,
    required Map<String, String> responses,
  }) async {
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
}
