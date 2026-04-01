import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';
import 'package:mesmer_digital_coaching/features/auth/user_entity.dart';
import 'package:mesmer_digital_coaching/features/dashboard/admin_dashboard_screen.dart';
import 'package:mesmer_digital_coaching/features/dashboard/supervisor_dashboard_screen.dart';
import 'package:mesmer_digital_coaching/features/dashboard/coach_dashboard_screen.dart';
import 'package:mesmer_digital_coaching/common/settings_screen.dart';
import 'package:mesmer_digital_coaching/features/workflow/coach/coach_list_screen.dart';
import 'package:mesmer_digital_coaching/features/dashboard/regional_coordinator_dashboard_screen.dart';

import 'package:mesmer_digital_coaching/features/workflow/coach/coach_enterprise_list_screen.dart';
import 'package:mesmer_digital_coaching/features/workflow/coaching/coach_session_list_screen.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_navigation_provider.dart';

class DashboardMainScreen extends ConsumerWidget {
  final Widget child;
  const DashboardMainScreen({super.key, required this.child});

  Widget _getDashboardBody(UserRole? role) {
    if (role == UserRole.programManager) return const AdminDashboardScreen();
    if (role == UserRole.regionalCoordinator) return RegionalCoordinatorDashboardScreen();
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
      else if (location.startsWith(AppRoutes.monitoring)) currentIndex = 3;
      else if (location.startsWith('/settings')) currentIndex = 4;
    } else if (userRole == UserRole.programManager) {
      if (location.startsWith(AppRoutes.institutions)) currentIndex = 1;
      else if (location.startsWith(AppRoutes.userManagement)) currentIndex = 2;
      else if (location.startsWith(AppRoutes.monitoring)) currentIndex = 3;
      else if (location.startsWith('/settings')) currentIndex = 4;
    } else if (userRole == UserRole.coach) {
      if (location.startsWith('/enterprises')) currentIndex = 1;
      else if (location.startsWith('/sessions')) currentIndex = 2;
      else if (location.startsWith('/chat')) currentIndex = 0;
      else if (location.contains('reports')) currentIndex = 3;
      else if (location.startsWith('/settings')) currentIndex = 4;
    } else if (userRole == UserRole.regionalCoordinator) {
      if (location.startsWith(AppRoutes.enterpriseList)) currentIndex = 1;
      else if (location.startsWith(AppRoutes.coachList)) currentIndex = 2;
      else if (location.startsWith(AppRoutes.scheduling)) currentIndex = 3;
      else if (location.startsWith(AppRoutes.supervisorReports)) currentIndex = 4;
      else if (location.startsWith('/settings')) currentIndex = 5;
    } else if (userRole == UserRole.enterprise) {
      if (location.startsWith(AppRoutes.enterpriseProgress)) currentIndex = 1;
      else if (location.startsWith(AppRoutes.enterpriseJourney)) currentIndex = 2;
      else if (location.startsWith('/settings')) currentIndex = 3;
      else currentIndex = 0;
    } else if (userRole == UserRole.meOfficer) {
      if (location.startsWith(AppRoutes.qcDashboard)) currentIndex = 1;
      else if (location.startsWith(AppRoutes.surveyHub)) currentIndex = 2;
      else if (location.startsWith(AppRoutes.enterpriseList)) currentIndex = 3;
      else if (location.contains('reports')) currentIndex = 4;
      else if (location.startsWith('/settings')) currentIndex = 5;
    } else if (userRole == UserRole.dataVerifier) {
      if (location.startsWith(AppRoutes.qcDashboard) || location == AppRoutes.dashboard) currentIndex = 0;
      else if (location.startsWith('/qc/history')) currentIndex = 1;
      else if (location.startsWith('/settings')) currentIndex = 2;
    } else if (userRole == UserRole.enumerator) {
      if (location.startsWith(AppRoutes.intakeRegister)) currentIndex = 1;
      else if (location.startsWith('/intake/baseline')) currentIndex = 2;
      else if (location.startsWith(AppRoutes.enumeratorSubmissions)) currentIndex = 3;
      else if (location.startsWith('/settings')) currentIndex = 4;
      else if (location.startsWith(AppRoutes.intakeQueue) || location == AppRoutes.dashboard) currentIndex = 0;
    } else if (userRole == UserRole.commsOfficer) {
      if (location.startsWith(AppRoutes.graduationReady) || location.startsWith(AppRoutes.certificateManagement)) currentIndex = 0;
      else if (location.startsWith(AppRoutes.successStories)) currentIndex = 1;
      else if (location.startsWith(AppRoutes.commsReports)) currentIndex = 2;
      else if (location.startsWith('/settings')) currentIndex = 3;
    } else {
      if (location.startsWith('/settings')) currentIndex = 1;
    }

    // Dynamically build the screens and navigation items based on role
    List<NavigationDestination> navItems = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded, color: Colors.blue),
        label: userRole == UserRole.dataVerifier ? 'QC Inbox' : 'Home',
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
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded, color: Colors.blue),
        label: 'Enterprises',
      ));
      
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.group_outlined),
        selectedIcon: Icon(Icons.group_rounded, color: Colors.blue),
        label: 'Coaches',
      ));

      navItems.add(const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month_rounded, color: Colors.blue),
        label: 'Scheduling',
      ));

      navItems.add(const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded, color: Colors.blue),
        label: 'Reports',
      ));
    } else if (userRole == UserRole.commsOfficer) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.workspace_premium_outlined),
        selectedIcon: Icon(Icons.workspace_premium, color: Colors.blue),
        label: 'Grad & Certs',
      ));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.description_outlined),
        selectedIcon: Icon(Icons.description, color: Colors.blue),
        label: 'Stories',
      ));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.analytics_outlined),
        selectedIcon: Icon(Icons.analytics, color: Colors.blue),
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
    } else if (userRole == UserRole.programManager) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.location_city_outlined),
        selectedIcon: Icon(Icons.location_city_rounded, color: Colors.blue),
        label: 'Regions',
      ));
      
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.people_alt_outlined),
        selectedIcon: Icon(Icons.people_alt_rounded, color: Colors.blue),
        label: 'People',
      ));

      navItems.add(const NavigationDestination(
        icon: Icon(Icons.fact_check_outlined),
        selectedIcon: Icon(Icons.fact_check_rounded, color: Colors.blue),
        label: 'QC & Reports',
      ));
    } else if (userRole == UserRole.enterprise) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.trending_up_outlined),
        selectedIcon: Icon(Icons.trending_up, color: Colors.blue),
        label: 'Progress',
      ));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.timeline_outlined),
        selectedIcon: Icon(Icons.timeline, color: Colors.blue),
        label: 'Journey',
      ));
    } else if (userRole == UserRole.meOfficer) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.verified_user_outlined),
        selectedIcon: Icon(Icons.verified_user_rounded, color: Colors.blue),
        label: 'QC Queue',
      ));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment_rounded, color: Colors.blue),
        label: 'Survey Hub',
      ));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.business_outlined),
        selectedIcon: Icon(Icons.business_rounded, color: Colors.blue),
        label: 'Enterprises',
      ));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded, color: Colors.blue),
        label: 'Reports',
      ));
    } else if (userRole == UserRole.dataVerifier) {
      // Home serves as Inbox for Verifiers
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.history_outlined),
        selectedIcon: Icon(Icons.history_rounded, color: Colors.blue),
        label: 'History',
      ));
    } else if (userRole == UserRole.enumerator) {
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded, color: Colors.blue),
        label: 'Register',
      ));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment_rounded, color: Colors.blue),
        label: 'Baseline',
      ));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.task_outlined),
        selectedIcon: Icon(Icons.task_rounded, color: Colors.blue),
        label: 'Submissions',
      ));
    }

    navItems.add(const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded, color: Colors.blue),
      label: 'Settings',
    ));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: isDark ? null : [
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
                case 3: targetPath = AppRoutes.monitoring; break;
                case 4: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.programManager) {
              switch (index) {
                case 1: targetPath = AppRoutes.institutions; break;
                case 2: targetPath = AppRoutes.userManagement; break;
                case 3: targetPath = AppRoutes.monitoring; break;
                case 4: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.regionalCoordinator) {
              switch (index) {
                case 1: targetPath = AppRoutes.enterpriseList; break;
                case 2: targetPath = AppRoutes.coachList; break;
                case 3: targetPath = AppRoutes.scheduling; break;
                case 4: targetPath = AppRoutes.supervisorReports; break;
                case 5: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.coach) {
              switch (index) {
                case 1: targetPath = AppRoutes.enterpriseList; break;
                case 2: targetPath = '/sessions'; break;
                case 3: targetPath = AppRoutes.reports; break;
                case 4: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.enterprise) {
              switch (index) {
                case 0: targetPath = AppRoutes.dashboard; break;
                case 1: targetPath = AppRoutes.enterpriseProgress; break;
                case 2: targetPath = AppRoutes.enterpriseJourney; break;
                case 3: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.meOfficer) {
              switch (index) {
                case 1: targetPath = AppRoutes.qcDashboard; break;
                case 2: targetPath = AppRoutes.surveyHub; break;
                case 3: targetPath = AppRoutes.enterpriseList; break;
                case 4: targetPath = AppRoutes.reports; break;
                case 5: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.dataVerifier) {
              switch (index) {
                case 0: targetPath = AppRoutes.dashboard; break;
                case 1: targetPath = '/qc/history'; break;
                case 2: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.enumerator) {
              switch (index) {
                case 0: targetPath = AppRoutes.intakeQueue; break;
                case 1: targetPath = AppRoutes.intakeRegister; break;
                case 2: targetPath = AppRoutes.intakeBaseline; break; // Corrected: Index 2 is Baseline
                case 3: targetPath = AppRoutes.enumeratorSubmissions; break;
                case 4: targetPath = '/settings'; break;
              }
            } else if (userRole == UserRole.commsOfficer) {
              switch (index) {
                case 0: targetPath = AppRoutes.graduationReady; break;
                case 1: targetPath = AppRoutes.successStories; break;
                case 2: targetPath = AppRoutes.commsReports; break;
                case 3: targetPath = '/settings'; break;
              }
            } else {
              if (index == 1) targetPath = '/settings';
            }
            
            context.go(targetPath);
          },
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          indicatorColor: isDark ? const Color(0xFF3D5AFE).withOpacity(0.3) : Theme.of(context).primaryColor.withOpacity(0.15),
          labelBehavior: navItems.length > 3 
            ? NavigationDestinationLabelBehavior.onlyShowSelected 
            : NavigationDestinationLabelBehavior.alwaysShow,
          destinations: navItems,
        ),
      ),
    );
  }
}


