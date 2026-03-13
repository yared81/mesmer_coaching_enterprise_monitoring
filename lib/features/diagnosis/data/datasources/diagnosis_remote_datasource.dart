import 'package:dio/dio.dart';
import '../models/diagnosis_template_model.dart';

abstract class DiagnosisRemoteDataSource {
  Future<DiagnosisTemplateModel> getLatestTemplate();
  Future<Map<String, dynamic>?> getReportBySessionId(String sessionId);
  Future<Map<String, dynamic>> submitDiagnosis({
    required String sessionId,
    required String templateId,
    required Map<String, String> responses,
  });
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
}
