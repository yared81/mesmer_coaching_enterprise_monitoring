import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/api_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/supervisor_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'app_routes.dart';

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
        if (role == UserRole.admin) return AppRoutes.dashboard; // Or specific admin route
        if (role == UserRole.supervisor) return AppRoutes.supervisorReports;
        return AppRoutes.enterpriseList; // Default for Coach
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // Dashboard - Simplified for now, role-based logic handles which screen to show
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) {
          final role = authState.user?.role;
          if (role == UserRole.admin) return const AdminDashboardScreen();
          if (role == UserRole.supervisor) return const SupervisorDashboardScreen();
          return const CoachDashboardScreen();
        },
      ),
      // Placeholder routes for other features to avoid router errors
      GoRoute(
        path: AppRoutes.enterpriseList,
        builder: (context, state) => const CoachDashboardScreen(), // TODO: Replace with real screens
      ),
      GoRoute(
        path: AppRoutes.supervisorReports,
        builder: (context, state) => const SupervisorDashboardScreen(), // TODO: Replace
      ),
    ],
  );
});
