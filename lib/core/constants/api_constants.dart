// TODO: Define all API base URLs, endpoint paths, and network timeouts
abstract class ApiConstants {
  // Base URL — set from .env or build config
  // Base URL — set from .env or build config using --dart-define-from-file
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.17.107.100:3000/api/v1',
  );

  // For manual string concatenations: '${ApiConstants.baseUrl}/path' (Guarantees NO trailing slash)
  static String get baseUrl => _rawBaseUrl.endsWith('/') ? _rawBaseUrl.substring(0, _rawBaseUrl.length - 1) : _rawBaseUrl;

  // For Dio BaseOptions: (Guarantees A trailing slash)
  static String get dioBaseUrl => _rawBaseUrl.endsWith('/') ? _rawBaseUrl : '$_rawBaseUrl/';

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
  static const String dashboard = 'dashboard';
  static const String userManagement = 'user-management/users';
  static const String institutions = 'user-management/institutions';
  static const String adminStats = 'dashboard/admin';
  static const String supervisorStats = 'dashboard/supervisor';
  static const String coachStats = 'dashboard/coach';
  static String coachStatsById(String id) => '/dashboard/coach/$id';

  // Enterprise Dashboard
  static const String enterpriseDashboardStats = 'enterprise-dashboard/stats';

  // Report Endpoints
  static const String reports = 'reports';
  static String enterpriseReportPdf(String id) => 'reports/enterprise/$id/pdf';
  static const String systemCsv = 'reports/system/csv';
  static const String weeklyReport = 'reports/weekly';

  // Session Endpoints
  static const String sessions = 'sessions';
  static const String phoneFollowups = 'phone-followups';
  
  // Audit Logs
  static const String audits = 'audits';
}

