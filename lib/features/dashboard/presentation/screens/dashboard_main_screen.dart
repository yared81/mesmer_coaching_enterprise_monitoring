import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/providers/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/entities/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/supervisor_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/screens/profile_screen.dart';

class DashboardMainScreen extends ConsumerStatefulWidget {
  const DashboardMainScreen({super.key});

  @override
  ConsumerState<DashboardMainScreen> createState() => _DashboardMainScreenState();
}

class _DashboardMainScreenState extends ConsumerState<DashboardMainScreen> {
  int _currentIndex = 0;

  Widget _getDashboardBody(UserRole? role) {
    if (role == UserRole.admin) return const AdminDashboardScreen();
    if (role == UserRole.supervisor) return const SupervisorDashboardScreen();
    return const CoachDashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role;

    final List<Widget> pages = [
      _getDashboardBody(userRole),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
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
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Colors.blue),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: Colors.blue),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
