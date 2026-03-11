// TODO: Define custom app-level exception classes
// Examples: ServerException, CacheException, UnauthorizedException, NetworkException

class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

// TODO: Add specific exception subclasses
