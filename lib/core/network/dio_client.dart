import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/network/offline_provider.dart';
import 'api_interceptor.dart';
import 'package:mesmer_digital_coaching/core/storage/secure_storage.dart';

class DioClient {
  static Dio createDio(
    SecureStorage secureStorage,
    OfflineModeNotifier offlineNotifier, {
    void Function()? onForceLogout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.dioBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.add(
      ApiInterceptor(secureStorage, offlineNotifier, onForceLogout: onForceLogout),
    );

    return dio;
  }
}
