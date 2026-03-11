// TODO: Implement Dio interceptor for JWT authentication
// Responsibilities:
// - Attach Bearer token to every request header
// - On 401 response: attempt token refresh via /auth/refresh
// - On refresh success: retry original request with new token
// - On refresh failure: clear tokens and redirect to login

import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  // TODO: Inject SecureStorage to read/write tokens

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Attach Authorization header
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: Handle 401 — refresh token or logout
    super.onError(err, handler);
  }
}
