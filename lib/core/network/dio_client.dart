import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'api_interceptor.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/secure_storage.dart';

class DioClient {
  static Dio createDio(SecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.dioBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.addAll([
      ApiInterceptor(secureStorage),
      LogInterceptor(responseBody: true, requestBody: true), // For dev visibility
    ]);

    return dio;
  }
}
