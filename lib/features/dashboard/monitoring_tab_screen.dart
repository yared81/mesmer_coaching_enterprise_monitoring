import 'package:flutter/material.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/qc/qc_dashboard_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/analytics/progress/supervisor_reports_screen.dart';

class MonitoringTabScreen extends StatelessWidget {
  const MonitoringTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitoring & Data'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.fact_check_rounded), text: 'QC Queue'),
              Tab(icon: Icon(Icons.analytics_rounded), text: 'MERL Reports'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            QcDashboardScreen(),
            SupervisorReportsScreen(),
          ],
        ),
      ),
    );
  }
}
