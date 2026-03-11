import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../constants/api_constants.dart';

class ApiInterceptor extends Interceptor {
  const ApiInterceptor(this._secureStorage);
  final SecureStorage _secureStorage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // TODO: Handle token refresh logic
      // This is complex - would typically involve a separate Dio instance to avoid infinite loop
      // and a lock to handle multiple parallel requests triggering refresh simultaneously.
      
      // If refresh fails or not implemented yet:
      // await _secureStorage.clearTokens();
      // TODO: Redirect to login (via some global state or event bus)
    }
    super.onError(err, handler);
  }
}
