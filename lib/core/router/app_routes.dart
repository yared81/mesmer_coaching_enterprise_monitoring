// TODO: Define all named route path constants
// Used by GoRouter and throughout the app for navigation

abstract class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Dashboard (role-based, same route — screen differs by role)
  static const String dashboard = '/dashboard';

  // Enterprise
  static const String enterpriseList = '/enterprises';
  static const String enterpriseDetail = '/enterprises/:id';
  static const String enterpriseCreate = '/enterprises/new';

  // Diagnosis
  static const String assessment = '/enterprises/:id/assessment';
  static const String assessmentResult = '/enterprises/:id/assessment/result';

  // Coaching
  static const String sessionList = '/enterprises/:id/sessions';
  static const String sessionCreate = '/enterprises/:id/sessions/new';
  static const String evidenceUpload = '/sessions/:sessionId/evidence';

  // Progress
  static const String progressDashboard = '/enterprises/:id/progress';

  // Reports
  static const String supervisorReports = '/reports';
}
