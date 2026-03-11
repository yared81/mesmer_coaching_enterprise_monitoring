// TODO: Configure GoRouter with all app routes and role-based guards
// - Redirect unauthenticated users to /login
// - Redirect authenticated users away from /login
// - Use ShellRoute for bottom navigation (coach view)
// - Role-based redirect: admin/supervisor → reports; coach → enterprise list

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // TODO: Watch authProvider to get current auth state
  // TODO: Define redirect logic based on user role
  // TODO: Register all routes using AppRoutes constants
  throw UnimplementedError('appRouterProvider not implemented yet');
});
