import 'package:flutter/material.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/qc/qc_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/analytics/progress/supervisor_reports_screen.dart';

/// Monitoring hub: QC Queue + MERL Reports in a tabbed layout.
/// NOTE: No Scaffold here — the outer DashboardMainScreen already provides one.
class MonitoringTabScreen extends StatelessWidget {
  const MonitoringTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Custom header that matches the blue app theme
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
                  tabs: const [
                    Tab(icon: Icon(Icons.fact_check_rounded), text: 'QC Queue'),
                    Tab(icon: Icon(Icons.analytics_rounded), text: 'MERL Reports'),
                  ],
                ),
              ],
            ),
          ),
          // Tab content fills the rest of available space
          const Expanded(
            child: TabBarView(
              children: [
                QcDashboardScreen(hideAppBar: true),
                SupervisorReportsScreen(hideAppBar: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
