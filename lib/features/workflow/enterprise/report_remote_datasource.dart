import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';

class ReportRemoteDatasource {
  ReportRemoteDatasource(this._dio);
  final Dio _dio;

  /// Downloads a single enterprise progress report as raw PDF bytes.
  Future<List<int>> downloadEnterprisePdf(String enterpriseId) async {
    final response = await _dio.get(
      ApiConstants.enterpriseReportPdf(enterpriseId),
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as List<int>;
  }

  /// Downloads the system-wide master list as raw CSV bytes.
  Future<List<int>> downloadMasterCsv() async {
    final response = await _dio.get(
      ApiConstants.systemCsv,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as List<int>;
  }

  /// Downloads the weekly coach activity summary as raw PDF bytes.
  Future<List<int>> downloadWeeklyReport() async {
    final response = await _dio.get(
      ApiConstants.weeklyReport,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as List<int>;
  }
}
