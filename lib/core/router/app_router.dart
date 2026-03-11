import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/providers/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/screens/login_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/supervisor_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/entities/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/presentation/screens/enterprise_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/presentation/screens/enterprise_form_screen.dart';

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
        final role = authState.user?.role;
        if (role == UserRole.admin) return AppRoutes.dashboard;
        if (role == UserRole.supervisor) return AppRoutes.supervisorReports;
        return AppRoutes.enterpriseList;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) {
          final role = authState.user?.role;
          if (role == UserRole.admin) return const AdminDashboardScreen();
          if (role == UserRole.supervisor) return const SupervisorDashboardScreen();
          return const CoachDashboardScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.enterpriseList,
        builder: (context, state) => const EnterpriseListScreen(),
      ),
      GoRoute(
        path: AppRoutes.enterpriseForm,
        builder: (context, state) => const EnterpriseFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.supervisorReports,
        builder: (context, state) => const SupervisorDashboardScreen(),
      ),
    ],
  );
});
