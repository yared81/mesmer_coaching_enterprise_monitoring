import 'package:flutter/material.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/qc/qc_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/analytics/progress/supervisor_reports_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/assessment_profile_list_screen.dart';

/// Monitoring hub: QC Queue + MERL Reports + Screening in a tabbed layout.
/// NOTE: No Scaffold here — the outer DashboardMainScreen already provides one.
class MonitoringTabScreen extends StatelessWidget {
  const MonitoringTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DefaultTabController(
          length: 3,
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
                        tabs: const [
                          Tab(icon: Icon(Icons.fact_check_rounded), text: 'QC Queue'),
                          Tab(icon: Icon(Icons.analytics_rounded), text: 'MERL Reports'),
                          Tab(icon: Icon(Icons.article_rounded), text: 'Screening'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tab content fills remainder
                const Expanded(
                  child: TabBarView(
                    children: [
                      QcDashboardScreen(hideAppBar: true),
                      SupervisorReportsScreen(hideAppBar: true),
                      AssessmentProfileListScreen(hideAppBar: true),
                    ],
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
