import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/providers/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/entities/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/supervisor_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/screens/settings_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/screens/coach_list_screen.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/screens/coach_enterprise_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/screens/coach_session_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/providers/dashboard_navigation_provider.dart';

class DashboardMainScreen extends ConsumerWidget {
  const DashboardMainScreen({super.key});

  Widget _getDashboardBody(UserRole? role) {
    if (role == UserRole.admin) return const AdminDashboardScreen();
    if (role == UserRole.supervisor) return const SupervisorDashboardScreen();
    return const CoachDashboardScreen();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role;
    final currentIndex = ref.watch(dashboardIndexProvider);

    // Dynamically build the screens and navigation items based on role
    List<Widget> pages = [_getDashboardBody(userRole)];
    List<NavigationDestination> navItems = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded, color: Colors.blue),
        label: 'Home',
      ),
    ];

    if (userRole == UserRole.supervisor) {
      pages.add(const CoachListScreen());
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.group_outlined),
        selectedIcon: Icon(Icons.group_rounded, color: Colors.blue),
        label: 'Coaches',
      ));
      
      pages.add(const Center(child: Text('Enterprise List Coming Soon')));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded, color: Colors.blue),
        label: 'Enterprises',
      ));

      pages.add(const Center(child: Text('Reports Coming Soon')));
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded, color: Colors.blue),
        label: 'Reports',
      ));
    } else if (userRole == UserRole.coach) {
      // Coach Specific Pages
      pages.add(const CoachEnterpriseListScreen());
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded, color: Colors.blue),
        label: 'Enterprises',
      ));

      pages.add(const CoachSessionListScreen());
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month_rounded, color: Colors.blue),
        label: 'Sessions',
      ));

      pages.add(const Center(child: Text('My Reports Screen'))); // Simplified for now
      navItems.add(const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded, color: Colors.blue),
        label: 'Reports',
      ));
    }

    pages.add(const SettingsScreen());
    navItems.add(const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded, color: Colors.blue),
      label: 'Settings',
    ));

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
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
            ref.read(dashboardIndexProvider.notifier).state = index;
          },
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: navItems,
        ),
      ),
    );
  }
}


