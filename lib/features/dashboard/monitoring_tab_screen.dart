import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/qc/qc_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/analytics/progress/supervisor_reports_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/assessment_profile_list_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';

/// Monitoring hub: QC Queue + MERL Reports + Screening dynamically loaded based on strict Role Based Access Control.
/// NOTE: No Scaffold here — the outer DashboardMainScreen already provides one.
class MonitoringTabScreen extends ConsumerWidget {
  const MonitoringTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role;
    
    // Determine which tabs to show based on role permissions
    final tabs = <Tab>[];
    final views = <Widget>[];

    // 1. QC Queue
    if ([UserRole.superAdmin, UserRole.programManager, UserRole.dataVerifier, UserRole.meOfficer].contains(role)) {
      tabs.add(const Tab(icon: Icon(Icons.fact_check_rounded), text: 'QC Queue'));
      views.add(const QcDashboardScreen(hideAppBar: true));
    }

    // 2. MERL Reports
    if ([UserRole.superAdmin, UserRole.programManager, UserRole.regionalCoordinator, UserRole.meOfficer].contains(role)) {
      tabs.add(const Tab(icon: Icon(Icons.analytics_rounded), text: 'MERL Reports'));
      views.add(const SupervisorReportsScreen(hideAppBar: true));
    }

    // 3. Screening / Templates
    if ([UserRole.superAdmin, UserRole.programManager, UserRole.meOfficer, UserRole.coach].contains(role)) {
      tabs.add(const Tab(icon: Icon(Icons.article_rounded), text: 'Screening'));
      views.add(const AssessmentProfileListScreen(hideAppBar: true));
    }
    
    // Fallback if role somehow has nothing
    if (tabs.isEmpty) {
      return const Center(child: Text('No monitoring modules available for your role.', style: TextStyle(color: Colors.blueGrey)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return DefaultTabController(
          length: tabs.length,
          child: SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                // Blue header matching app theme
                Container(
                  color: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Monitoring & Data',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                        tabs: tabs,
                      ),
                    ],
                  ),
                ),
                // Tab content fills remainder
                Expanded(
                  child: TabBarView(
                    children: views,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
