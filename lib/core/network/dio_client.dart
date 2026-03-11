import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_interceptor.dart';
import '../storage/secure_storage.dart';

class DioClient {
  static Dio createDio(SecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
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
