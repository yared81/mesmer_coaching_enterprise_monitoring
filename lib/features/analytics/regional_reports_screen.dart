import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/features/analytics/progress/supervisor_reports_screen.dart';
import 'package:mesmer_digital_coaching/features/dashboard/widgets/program_funnel_widget.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_provider.dart';

class RegionalReportsScreen extends ConsumerWidget {
  const RegionalReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Regional Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Funnel Section
            const Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: ProgramFunnelWidget(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Detailed Reports List (Re-using SupervisorReportsScreen body)
            const Text(
              'MERL Detailed Analysis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 600, // Fixed height for Nested scrolling feel
              child: const SupervisorReportsScreen(hideAppBar: true),
            ),
          ],
        ),
      ),
    );
  }
}
