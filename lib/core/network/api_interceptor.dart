import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/storage/secure_storage.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/network/offline_provider.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._secureStorage, this._offlineNotifier);
  final SecureStorage _secureStorage;
  final OfflineModeNotifier _offlineNotifier;

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
    // 1. Detect Connection Failures
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.badResponse && err.response?.statusCode == 503)) {
      
      _offlineNotifier.setOffline(true);
      // We don't call super.onError yet because we want the repository to handle the fallback
    }

    // 2. Clear Offline Mode on successful manual retry or specific status codes if needed
    // (Usually handled by explicit 'Retry' buttons in UI)

    // 3. Handle Token Refresh (Original Logic)
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != 'auth/refresh' &&
        err.requestOptions.path != 'auth/login') {

      if (_isRefreshing) {
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

        final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.dioBaseUrl));
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

          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryDio = Dio(BaseOptions(baseUrl: ApiConstants.dioBaseUrl));
          final retryResponse = await retryDio.fetch(err.requestOptions);

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
      final retryDio = Dio(BaseOptions(baseUrl: ApiConstants.dioBaseUrl));
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
