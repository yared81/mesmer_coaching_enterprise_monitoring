// TODO: Define all named route path constants
// Used by GoRouter and throughout the app for navigation

abstract class AppRoutes {
  // Auth & Settings
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String notifications = '/notifications';

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
  static const String evidenceUpload = '/sessions/:sessionId/evidence/:enterpriseId';

  // Coaches (Supervisor Management)
  static const String coachList = '/coaches';
  static const String addCoach = '/coaches/new';
  static const String coachProfile = '/coaches/:id';
  static const String coachDetail = '/coaches';

  // Progress
  static const String progressDashboard = '/enterprises/:id/progress';
  
  // Enterprise self (enterprise role)
  static const String enterpriseProfile = '/enterprise/profile';
  static const String enterpriseProgress = '/enterprise/progress';
  static const String enterpriseJourney = '/enterprise/journey';

  // Monitoring & Reports
  static const String surveyHub = '/survey-hub';
  static const String monitoring = '/monitoring-hub';
  static const String supervisorReports = '/regional-reports'; 
  static const String reports = '/reports';
  static const String diagnosis = '/diagnosis';
  
  // Enumerator / Intake Routes
  static const String intakeQueue = '/intake';
  static const String intakeRegister = '/intake/register';
  static const String intakeConsent = '/intake/consent/:id';
  static const String intakeBaseline = '/intake/baseline/:id';
  static const String intakeSubmissions = '/intake/submissions';
  static const String enumeratorSubmissions = '/intake/my-submissions';

  // Comms Officer
  static const String graduationReady = '/comms/graduation-ready';
  static const String certificateManagement = '/comms/certificates';
  static const String successStories = '/comms/stories';
  static const String commsReports = '/comms/reports';

  // Templates
  static const String templateList = '/supervisor/templates';
  static const String templateBuilder = '/supervisor/templates/build';
  static const String chat = '/chat';
  static const String qcDashboard = '/qc-dashboard';
  static const String qcHistory = '/qc/history';
  static const String qcDetail = '/qc/detail/:id';
  static const String userManagement = '/admin/users';
  static const String auditLogs = '/admin/audit-logs';
  static const String institutions = '/admin/organizations';
  static const String coachCrm = '/coach/portfolio';
  static const String calendar = '/calendar';
  static const String scheduling = '/scheduling';
  
  // Training (Trainer Role)
  static const String trainingDashboard = '/training';
  static const String trainingCreate = '/training/new';
  static const String trainingDetail = '/training/:id';
  static const String trainingAttendance = '/training/:id/attendance';
  static const String trainingEvaluation = '/training/:id/evaluation';
}

