// TODO: Define all API base URLs, endpoint paths, and network timeouts
abstract class ApiConstants {
  // Base URL — set from .env or build config
  // Base URL — set from .env or build config using --dart-define-from-file
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  // TODO: Add timeout values
  // TODO: Add all endpoint path constants per module
  //   e.g. static const String login = '/auth/login';
}
