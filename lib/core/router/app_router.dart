import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/providers/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/screens/login_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/screens/profile_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/screens/change_password_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/dashboard_main_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/entities/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/supervisor_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/screens/coach_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/screens/coach_session_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/screens/add_session_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/screens/settings_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/screens/session_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/domain/entities/coaching_session_entity.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/presentation/screens/enterprise_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/presentation/screens/enterprise_form_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/presentation/screens/enterprise_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/screens/add_coach_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/screens/coach_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/diagnosis/presentation/screens/assessment_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/diagnosis/presentation/screens/template_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/diagnosis/presentation/screens/template_builder_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/diagnosis/domain/entities/diagnosis_template_entity.dart';

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
            builder: (context, state) => const TemplateListScreen(),
          ),
          GoRoute(
            path: AppRoutes.templateBuilder,
            builder: (context, state) {
              final template = state.extra as DiagnosisTemplateEntity?;
              return TemplateBuilderScreen(existingProfile: template);
            },
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
    return CoachDashboardScreen();
  }
}
