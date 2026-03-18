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
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_profile_screen.dart';

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
            builder: (context, state) => const EnterpriseListScreen(),
          ),
          GoRoute(
            path: AppRoutes.supervisorReports,
            builder: (context, state) => const Scaffold(
              body: SizedBox.shrink(),
            ),
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
            builder: (context, state) => const CoachListScreen(),
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
    if (role == UserRole.admin) return AdminDashboardScreen();
    if (role == UserRole.supervisor) return const SupervisorDashboardScreen();
    if (role == UserRole.enterprise) return const EnterpriseDashboardScreen();
    return CoachDashboardScreen();
  }
}
