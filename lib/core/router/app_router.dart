import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/login_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/common/profile_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/common/change_password_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_main_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/supervisor_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/admin_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/coach_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coach/coach_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coach_session_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/add_session_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/common/settings_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/session_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_session_entity.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_form_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coach/add_coach_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coach/coach_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/assessment_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/assessment_profile_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/assessment_profile_builder_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/diagnosis_template_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/communication/chat_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/phone_followup_log_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_profile_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/qc/qc_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/qc/qc_record_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/qc/qc_audit_history_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/me_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/trainer_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/role_permissions.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/user_management_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/institution_management_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/coach_crm_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/calendar_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/analytics/progress/supervisor_reports_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/analytics/cross_sector_analytics_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/monitoring_tab_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/regional_coordinator_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/regional_enterprise_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coach/regional_coach_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/scheduling/scheduling_hub_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/analytics/regional_reports_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/survey/survey_management_hub_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/training/training_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/training_attendance_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/training/training_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/intake/intake_queue_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/intake/baseline_assessment_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/intake/enumerator_submissions_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/intake/baseline_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      
      // 1. If not authenticated and not on login page, redirect to login
      if (authState.status == AuthStatus.unauthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }

      // 2. If authenticated and on login page, redirect to appropriate dashboard
      if (authState.status == AuthStatus.authenticated && isLoggingIn) {
        return AppRoutes.dashboard;
      }

      // 3. RBAC Guard: Verify role permissions for the current path
      if (authState.status == AuthStatus.authenticated) {
        final user = authState.user!;
        final path = state.matchedLocation;
        
        // Skip check for basic shared paths
        final sharedPaths = [
          AppRoutes.login,
          AppRoutes.dashboard, // Home is handled by _DashboardHome
          AppRoutes.profile,
          AppRoutes.changePassword,
          '/settings',
          AppRoutes.chat,
          AppRoutes.monitoring,
          AppRoutes.supervisorReports,
        ];
        
        if (!sharedPaths.contains(path)) {
          if (!RolePermissions.canAccess(user.role, path)) {
            debugPrint('🛡️ RBAC: Blocking ${user.role} from accessing $path');
            return AppRoutes.dashboard; // Send back to home
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardMainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const _DashboardHome(),
          ),
          GoRoute(
            path: AppRoutes.enterpriseList,
            builder: (context, state) {
              final role = ref.watch(authProvider).user?.role;
              if (role == UserRole.regionalCoordinator) return const RegionalEnterpriseListScreen();
              return const EnterpriseListScreen();
            },
          ),
          GoRoute(
            path: AppRoutes.supervisorReports,
            builder: (context, state) {
              final role = ref.watch(authProvider).user?.role;
              if (role == UserRole.regionalCoordinator) return const RegionalReportsScreen();
              return const SupervisorReportsScreen();
            },
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const SupervisorReportsScreen(),
          ),
          GoRoute(
            path: AppRoutes.scheduling,
            builder: (context, state) {
              final role = ref.watch(authProvider).user?.role;
              if (role == UserRole.regionalCoordinator) return const SchedulingHubScreen();
              return const Scaffold(body: Center(child: Text('Scheduling Screen (Coming Soon)')));
            },
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const CrossSectorAnalyticsScreen(),
          ),

          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.changePassword,
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: AppRoutes.surveyHub,
            builder: (context, state) => const SurveyManagementHubScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/sessions',
            builder: (context, state) => const CoachSessionListScreen(),
          ),
          GoRoute(
            path: '/sessions/new',
            builder: (context, state) => const AddSessionScreen(),
          ),
          GoRoute(
            path: '/sessions/detail',
            builder: (context, state) {
              final session = state.extra as CoachingSessionEntity;
              return SessionDetailScreen(session: session);
            },
          ),
          GoRoute(
            path: '/coaches',
            builder: (context, state) {
              final role = ref.watch(authProvider).user?.role;
              if (role == UserRole.regionalCoordinator) return const RegionalCoachListScreen();
              return const CoachListScreen();
            },
          ),
          GoRoute(
            path: AppRoutes.addCoach,
            builder: (context, state) => const AddCoachScreen(),
          ),
          GoRoute(
            path: '/coaches/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CoachDetailScreen(coachId: id);
            },
          ),
          GoRoute(
            path: '/enterprises/detail/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EnterpriseDetailScreen(enterpriseId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.phoneLogCreate,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PhoneFollowupLogScreen(enterpriseId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.enterpriseForm,
            builder: (context, state) => const EnterpriseFormScreen(),
          ),
          GoRoute(
            path: AppRoutes.diagnosis,
            builder: (context, state) {
              final sessionId = state.extra as String;
              return AssessmentScreen(sessionId: sessionId);
            },
          ),
          GoRoute(
            path: AppRoutes.templateList,
            builder: (context, state) => const AssessmentProfileListScreen(),
          ),
          GoRoute(
            path: AppRoutes.templateBuilder,
            builder: (context, state) {
              final template = state.extra as DiagnosisTemplateEntity?;
              return AssessmentProfileBuilderScreen(existingProfile: template);
            },
          ),
          GoRoute(
            path: AppRoutes.chat,
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: AppRoutes.enterpriseProfile,
            builder: (context, state) => const EnterpriseProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.qcDashboard,
            builder: (context, state) => const QcDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.qcHistory,
            builder: (context, state) => const QcAuditHistoryScreen(hideAppBar: true),
          ),
          GoRoute(
            path: AppRoutes.qcDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return QcRecordDetailScreen(auditId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.userManagement,
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.institutions,
            builder: (context, state) => const InstitutionManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachCrm,
            builder: (context, state) => const CoachCrmScreen(),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: AppRoutes.trainingDashboard,
            builder: (context, state) => const TrainerDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.trainingCreate,
            builder: (context, state) => const Scaffold(body: Center(child: Text('Create Training (Coming Soon)'))),
          ),
          GoRoute(
            path: AppRoutes.trainingDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Scaffold(body: Center(child: Text('Training Detail: $id')));
            },
          ),
          GoRoute(
            path: AppRoutes.trainingAttendance,
            builder: (context, state) {
              final training = state.extra as TrainingEntity;
              return TrainingAttendanceScreen(training: training);
            },
          ),
          // Enumerator / Intake Routes
          GoRoute(
            path: AppRoutes.intakeQueue,
            builder: (context, state) => const IntakeQueueScreen(),
          ),
          GoRoute(
            path: AppRoutes.intakeRegister,
            builder: (context, state) => const EnterpriseFormScreen(),
          ),
          GoRoute(
            path: AppRoutes.intakeSubmissions,
            builder: (context, state) => const BaselineListScreen(),
          ),
          GoRoute(
            path: AppRoutes.intakeBaseline,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return BaselineAssessmentScreen(enterpriseId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.enumeratorSubmissions,
            builder: (context, state) => const EnumeratorSubmissionsScreen(),
          ),
        ],
      ),
    ],
  );
});

class _DashboardHome extends ConsumerWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role;
    if (role == UserRole.programManager || role == UserRole.superAdmin) return AdminDashboardScreen();
    if (role == UserRole.regionalCoordinator) return RegionalCoordinatorDashboardScreen();
    if (role == UserRole.meOfficer) return const MeDashboardScreen();
    if (role == UserRole.trainer) return const TrainerDashboardScreen();
    if (role == UserRole.enterprise) return const EnterpriseDashboardScreen();
    if (role == UserRole.coach) return CoachDashboardScreen();
    if (role == UserRole.dataVerifier) return const QcDashboardScreen(hideAppBar: true);
    if (role == UserRole.enumerator) return const IntakeQueueScreen();
    
    return const Scaffold(
      body: Center(
        child: Text('Security Error: Invalid Role Configuration.\nPlease contact support.', textAlign: TextAlign.center),
      ),
    );
  }
}
