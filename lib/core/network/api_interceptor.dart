import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/secure_storage.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._secureStorage);
  final SecureStorage _secureStorage;

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

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
    // Only attempt refresh for 401s (not on the auth endpoints themselves)
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != 'auth/refresh' &&
        err.requestOptions.path != 'auth/login') {

      if (_isRefreshing) {
        // Queue this request to retry after the refresh completes
        _pendingRequests.add(_PendingRequest(err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null) {
          _rejectAll();
          super.onError(err, handler);
          return;
        }

        // Create a separate Dio to avoid interceptor loop
        final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
        final response = await refreshDio.post(
          'auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          final newAccessToken = response.data['accessToken'] as String;
          await _secureStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );

          // Retry the original failed request with the new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
          final retryResponse = await retryDio.fetch(err.requestOptions);

          // Retry all queued requests too
          _retryAll(newAccessToken);

          handler.resolve(retryResponse);
        } else {
          await _secureStorage.clearTokens();
          _rejectAll();
          super.onError(err, handler);
        }
      } catch (_) {
        await _secureStorage.clearTokens();
        _rejectAll();
        super.onError(err, handler);
      } finally {
        _isRefreshing = false;
        _pendingRequests.clear();
      }
      return;
    }

    super.onError(err, handler);
  }

  void _retryAll(String newToken) {
    for (final pending in _pendingRequests) {
      pending.options.headers['Authorization'] = 'Bearer $newToken';
      final retryDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      retryDio.fetch(pending.options).then(
        (response) => pending.handler.resolve(response),
        onError: (e) => pending.handler.reject(e is DioException ? e : DioException(requestOptions: pending.options)),
      );
    }
  }

  void _rejectAll() {
    for (final pending in _pendingRequests) {
      pending.handler.reject(DioException(requestOptions: pending.options));
    }
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}
