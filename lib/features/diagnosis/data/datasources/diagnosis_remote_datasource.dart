import 'package:dio/dio.dart';
import '../models/diagnosis_template_model.dart';

abstract class DiagnosisRemoteDataSource {
  Future<DiagnosisTemplateModel> getLatestTemplate();
  Future<bool> submitDiagnosis({
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
    final response = await dio.get('/api/v1/diagnosis/template/latest');
    
    if (response.data['success']) {
      return DiagnosisTemplateModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch latest template');
    }
  }

  @override
  Future<bool> submitDiagnosis({
    required String sessionId,
    required String templateId,
    required Map<String, String> responses,
  }) async {
    final response = await dio.post('/api/v1/diagnosis/reports', data: {
      'session_id': sessionId,
      'template_id': templateId,
      'responses': responses,
    });

    return response.data['success'] == true;
  }
}
