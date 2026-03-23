import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';

class RolePermissions {
  static const Map<UserRole, List<String>> _allowedPrefixes = {
    UserRole.superAdmin: ['/'],
    UserRole.programManager: ['/'],
    UserRole.regionalCoordinator: [
      AppRoutes.dashboard,
      '/coaches',
      '/enterprises',
      '/sessions',
      AppRoutes.scheduling,
      AppRoutes.supervisorReports,
      '/analytics',
      '/qc/history',
      '/profile',
      AppRoutes.changePassword,
      '/settings',
      AppRoutes.chat,
    ],
    UserRole.coach: [
      AppRoutes.dashboard,
      '/sessions',
      '/enterprises',
      '/enterprises/detail',
      '/reports',
      '/diagnosis',
      AppRoutes.intakeQueue,
      AppRoutes.intakeRegister,
      AppRoutes.intakeBaseline,
      AppRoutes.enumeratorSubmissions,
      '/profile',
      AppRoutes.changePassword,
      '/settings',
      AppRoutes.chat,
    ],
    UserRole.meOfficer: [
      AppRoutes.dashboard,
      AppRoutes.qcDashboard,
      AppRoutes.surveyHub,
      AppRoutes.enterpriseList,
      '/qc',
      '/enterprises/detail',
      '/profile',
      AppRoutes.changePassword,
      '/settings',
    ],

    UserRole.trainer: [
      AppRoutes.dashboard,
      '/training',
      '/profile',
      AppRoutes.changePassword,
      '/settings',
    ],
    UserRole.enterprise: [
      AppRoutes.dashboard,
      AppRoutes.enterpriseProfile,
      AppRoutes.chat,
      '/profile',
      AppRoutes.changePassword,
      '/settings',
    ],
    UserRole.dataVerifier: [
      AppRoutes.dashboard,
      AppRoutes.qcDashboard,
      '/qc',
      '/profile',
      AppRoutes.changePassword,
      '/settings',
    ],
  };

  static bool canAccess(UserRole role, String path) {
    if (role == UserRole.superAdmin || role == UserRole.programManager) return true;

    final allowed = _allowedPrefixes[role] ?? [];
    
    // Check if the current path starts with any of the allowed prefixes
    return allowed.any((prefix) => path == prefix || path.startsWith('$prefix/'));
  }
}
