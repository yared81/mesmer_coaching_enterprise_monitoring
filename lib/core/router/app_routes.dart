// TODO: Define all named route path constants
// Used by GoRouter and throughout the app for navigation

abstract class AppRoutes {
  // Auth & Settings
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';

  // Dashboard (role-based, same route — screen differs by role)
  static const String dashboard = '/dashboard';

  // Enterprise
  static const String enterpriseList = '/enterprises';
  static const String enterpriseDetail = '/enterprises/:id';
  static const String enterpriseForm = '/enterprises/new';

  // Diagnosis
  static const String assessment = '/enterprises/:id/assessment';
  static const String assessmentResult = '/enterprises/:id/assessment/result';

  // Coaching
  static const String sessionList = '/enterprises/:id/sessions';
  static const String sessionCreate = '/enterprises/:id/sessions/new';
  static const String phoneLogCreate = '/enterprises/:id/sessions/phone-log';
  static const String evidenceUpload = '/sessions/:sessionId/evidence';

  // Coaches (Supervisor Management)
  static const String coachList = '/coaches';
  static const String addCoach = '/coaches/new';
  static const String coachProfile = '/coaches/:id';
  static const String coachDetail = '/coaches';

  // Progress
  static const String progressDashboard = '/enterprises/:id/progress';
  
  // Enterprise self (enterprise role)
  static const String enterpriseProfile = '/enterprise/profile';

  // Reports
  static const String supervisorReports = '/reports';
  static const String diagnosis = '/diagnosis';

  // Templates
  static const String templateList = '/supervisor/templates';
  static const String templateBuilder = '/supervisor/templates/build';
  static const String chat = '/chat';
  static const String qcDashboard = '/qc-dashboard';
  static const String userManagement = '/admin/users';
  static const String institutions = '/admin/organizations';
}

