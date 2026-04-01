import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'api_interceptor.dart';
import 'package:mesmer_digital_coaching/core/storage/secure_storage.dart';

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
