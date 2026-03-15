// TODO: Define all API base URLs, endpoint paths, and network timeouts
abstract class ApiConstants {
  // Base URL — set from .env or build config
  // Base URL — set from .env or build config using --dart-define-from-file
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1/',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Auth Endpoints
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refresh = 'auth/refresh';
  static const String me = 'auth/me';
  static const String forgotPassword = 'auth/forgot-password';

  // Enterprise Endpoints
  static const String enterprises = 'enterprises';

  // Dashboard Endpoints
  static const String adminStats = 'dashboard/admin';
  static const String supervisorStats = 'dashboard/supervisor';
  static const String coachStats = 'dashboard/coach';
  static String coachStatsById(String id) => '/dashboard/coach/$id';

  // Enterprise Dashboard
  static const String enterpriseDashboardStats = '/enterprise-dashboard/stats';

  // Session Endpoints
  static const String sessions = 'sessions';
}
