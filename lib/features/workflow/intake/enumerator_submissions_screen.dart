import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';

class EnumeratorSubmissionsScreen extends ConsumerWidget {
  const EnumeratorSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Submissions', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'RECENT'),
              Tab(text: 'PENDING QC'),
              Tab(text: 'CORRECTIONS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRecentList(context),
            _buildStatsList('Pending QC'),
            _buildCorrectionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'RECENT SUBMISSIONS (Last 7 days)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
          canEdit: true,
          hoursLeft: 47,
          context: context,
        ),
        _buildSubmissionCard(
          name: 'Tesfa Bakery - Baseline',
          date: 'Mar 22, 2025, 2:15 PM',
          status: 'Correction Requested',
          statusColor: Colors.red,
          canEdit: true,
          note: 'Verifier: "Missing storefront photo"',
          context: context,
        ),
        _buildSubmissionCard(
          name: 'Kebede Traders - Baseline',
          date: 'Mar 20, 2025, 11:00 AM',
          status: 'Verified ✓',
          statusColor: Colors.green,
          canEdit: false,
          context: context,
        ),
      ],
    );
  }

  Widget _buildStatsList(String status) {
    return Center(child: Text('$status view coming soon'));
  }

  Widget _buildCorrectionsList() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text('NEEDS CORRECTION (2)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: AppSpacing.md),
        _buildSubmissionCard(
          name: 'Hiwot Cafe - Baseline',
          date: 'Mar 19, 2025',
          status: 'Needs Correction',
          statusColor: Colors.red,
          canEdit: true,
          note: 'Correction needed: Missing consent form\nDeadline: Mar 25, 2025',
        ),
      ],
    );
  }

  Widget _buildSubmissionCard({
    required String name,
    required String date,
    required String status,
    required Color statusColor,
    required bool canEdit,
    required BuildContext context,
    int? hoursLeft,
    String? note,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(status == 'Verified ✓' ? Icons.check_circle : (statusColor == Colors.red ? Icons.warning : Icons.access_time), color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
            const SizedBox(height: 4),
            Text('Submitted: $date', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(fontSize: 12)),
                Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
              ],
            ),
            if (hoursLeft != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text(
                      'Edit window: \$hoursLeft hours remaining',
                      style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(note, style: const TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('VIEW'),
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor == Colors.red ? Colors.red : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(statusColor == Colors.red ? 'FIX NOW' : 'EDIT'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
