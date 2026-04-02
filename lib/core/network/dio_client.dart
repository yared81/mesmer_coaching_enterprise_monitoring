import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/network/offline_provider.dart';
import 'api_interceptor.dart';
import 'package:mesmer_digital_coaching/core/storage/secure_storage.dart';

class DioClient {
  static Dio createDio(SecureStorage secureStorage, OfflineModeNotifier offlineNotifier) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.dioBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.addAll([
      ApiInterceptor(secureStorage, offlineNotifier),
      LogInterceptor(responseBody: true, requestBody: true), // For dev visibility
    ]);

    return dio;
  }
}
