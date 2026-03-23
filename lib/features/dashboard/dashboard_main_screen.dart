import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/admin_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/supervisor_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/coach_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/common/settings_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coach/coach_list_screen.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coach/coach_enterprise_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coach_session_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_navigation_provider.dart';

class DashboardMainScreen extends ConsumerWidget {
  final Widget child;
  const DashboardMainScreen({super.key, required this.child});

  Widget _getDashboardBody(UserRole? role) {
    if (role == UserRole.programManager) return const AdminDashboardScreen();
    if (role == UserRole.regionalCoordinator) return const SupervisorDashboardScreen();
    return const CoachDashboardScreen();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role;
    final location = GoRouterState.of(context).matchedLocation;
    
    // Determine current index based on location and role
    int currentIndex = 0;
    
    if (userRole == UserRole.superAdmin) {
      if (location.startsWith(AppRoutes.userManagement)) currentIndex = 1;
      else if (location.startsWith(AppRoutes.enterpriseList)) currentIndex = 2;
      else if (location.startsWith('/monitoring')) currentIndex = 3;
      else if (location.startsWith('/settings')) currentIndex = 4;
    } else if (userRole == UserRole.coach) {
      if (location.startsWith('/enterprises')) currentIndex = 1;
      else if (location.startsWith('/sessions')) currentIndex = 2;
      else if (location.startsWith('/chat')) currentIndex = 0;
      else if (location.contains('reports')) currentIndex = 3;
      else if (location.startsWith('/settings')) currentIndex = 4;
    } else if (userRole == UserRole.regionalCoordinator) {
      if (location.startsWith('/coaches')) currentIndex = 1;
      else if (location.startsWith('/enterprises')) currentIndex = 2;
      else if (location.startsWith('/chat')) currentIndex = 0;
      else if (location.startsWith('/reports')) currentIndex = 3;
      else if (location.startsWith('/settings')) currentIndex = 4;
    } else if (userRole == UserRole.enterprise) {
      if (location.startsWith(AppRoutes.enterpriseProfile) || location.contains('progress')) currentIndex = 1;
      else if (location.startsWith('/chat')) currentIndex = 0;
      else if (location.startsWith('/settings')) currentIndex = 2;
    } else {
      if (location.startsWith('/settings')) currentIndex = 1;
    }

    // Dynamically build the screens and navigation items based on role
    List<NavigationDestination> navItems = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded, color: Colors.blue),
        label: 'Home',
      ),
    ];
    
    if (userRole == UserRole.superAdmin) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.people_alt_outlined),
        selectedIcon: Icon(Icons.people_alt_rounded, color: Colors.blue),
        label: 'Users',
      ));
      
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded, color: Colors.blue),
        label: 'Enterprises',
      ));

      navItems.add(const NavigationDestination(
        icon: Icon(Icons.analytics_outlined),
        selectedIcon: Icon(Icons.analytics_rounded, color: Colors.blue),
        label: 'Monitoring',
      ));
    } else if (userRole == UserRole.regionalCoordinator) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.group_outlined),
        selectedIcon: Icon(Icons.group_rounded, color: Colors.blue),
        label: 'Coaches',
      ));
      
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded, color: Colors.blue),
        label: 'Enterprises',
      ));

      navItems.add(const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded, color: Colors.blue),
        label: 'Reports',
      ));
    } else if (userRole == UserRole.coach) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded, color: Colors.blue),
        label: 'Enterprises',
      ));

      navItems.add(const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month_rounded, color: Colors.blue),
        label: 'Sessions',
      ));

      navItems.add(const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded, color: Colors.blue),
        label: 'Reports',
      ));
    } else if (userRole == UserRole.enterprise) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.analytics_outlined),
        selectedIcon: Icon(Icons.analytics_rounded, color: Colors.blue),
        label: 'Progress',
      ));
    }

    navItems.add(const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded, color: Colors.blue),
      label: 'Settings',
    ));

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            String targetPath = AppRoutes.dashboard;
            
            if (userRole == UserRole.superAdmin) {
              switch (index) {
                case 1: targetPath = AppRoutes.userManagement; break;
                case 2: targetPath = AppRoutes.enterpriseList; break;
                case 3: targetPath = '/monitoring'; break;
                case 4: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.regionalCoordinator) {
              switch (index) {
                case 1: targetPath = '/coaches'; break;
                case 2: targetPath = AppRoutes.enterpriseList; break;
                case 3: targetPath = AppRoutes.supervisorReports; break;
                case 4: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.coach) {
              switch (index) {
                case 1: targetPath = AppRoutes.enterpriseList; break;
                case 2: targetPath = '/sessions'; break;
                case 3: targetPath = '/reports'; break;
                case 4: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.enterprise) {
              switch (index) {
                case 1: targetPath = AppRoutes.enterpriseProfile; break;
                case 2: targetPath = '/settings'; break;
              }
            } else {
              if (index == 1) targetPath = '/settings';
            }
            
            context.go(targetPath);
          },
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.15),
          labelBehavior: navItems.length > 3 
            ? NavigationDestinationLabelBehavior.onlyShowSelected 
            : NavigationDestinationLabelBehavior.alwaysShow,
          destinations: navItems,
        ),
      ),
    );
  }
}


