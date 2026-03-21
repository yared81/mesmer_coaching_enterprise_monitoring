import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';

class RolePermissions {
  static const Map<UserRole, List<String>> _allowedPrefixes = {
    UserRole.superAdmin: ['/'],
    UserRole.admin: ['/'],
    UserRole.supervisor: [
      AppRoutes.dashboard,
      '/coaches',
      '/enterprises',
      '/sessions',
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
      '/profile',
      AppRoutes.changePassword,
      '/settings',
      AppRoutes.chat,
    ],
    UserRole.meOfficer: [
      AppRoutes.dashboard,
      AppRoutes.qcDashboard,
      '/enterprises/detail',
      '/profile',
      AppRoutes.changePassword,
      '/settings',
    ],
    UserRole.programManager: [
      AppRoutes.dashboard,
      '/enterprises',
      '/profile',
      AppRoutes.changePassword,
      '/settings',
    ],
    UserRole.trainer: [
      AppRoutes.dashboard,
      '/trainings',
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
  };

  static bool canAccess(UserRole role, String path) {
    if (role == UserRole.superAdmin || role == UserRole.admin) return true;

    final allowed = _allowedPrefixes[role] ?? [];
    
    // Check if the current path starts with any of the allowed prefixes
    return allowed.any((prefix) => path == prefix || path.startsWith('$prefix/'));
  }
}
