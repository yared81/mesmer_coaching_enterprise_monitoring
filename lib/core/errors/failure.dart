import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);

  factory Failure.fromException(Object e) {
    if (e is DioException) {
      return _handleDioError(e);
    }
    return ServerFailure(message: e.toString());
  }

  static Failure _handleDioError(DioException e) {
    String message = 'An unexpected error occurred';
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'The connection timed out. Please check your internet.');
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'No internet connection or server is unreachable.');
      case DioExceptionType.badResponse:
        final response = e.response;
        if (response != null) {
          final data = response.data;
          // Try to extract the message from the backend response JSON
          if (data is Map && data.containsKey('message')) {
            message = data['message'].toString();
          } else if (data is Map && data.containsKey('error')) {
            message = data['error'].toString();
          } else {
            message = 'Server Error (${response.statusCode}): ${response.statusMessage ?? "Unknown"}';
          }
          
          if (response.statusCode == 401) {
            return UnauthorizedFailure(message: message);
          }
        }
        return ServerFailure(message: message);
      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Request was cancelled.');
      default:
        return ServerFailure(message: e.message ?? 'Internal system error');
    }
  }
}

class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server Error'}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No Internet Connection'}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache Error'}) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({String message = 'Unauthorized'}) : super(message);
}

class LocalFailure extends Failure {
  const LocalFailure({String message = 'Local data error'}) : super(message);
}
