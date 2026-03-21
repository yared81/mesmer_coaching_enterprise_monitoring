import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/stat_card.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'report_provider.dart';

class SupervisorReportsScreen extends ConsumerWidget {
  const SupervisorReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We reuse enterpriseListProvider to get all enterprises
    final enterprisesAsync = ref.watch(enterpriseListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('System Health & Reports'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ActionChip(
              avatar: const Icon(Icons.file_download_rounded, size: 16, color: Colors.blue),
              label: const Text('Export System CSV', style: TextStyle(color: Colors.blue)),
              backgroundColor: Colors.blue.withOpacity(0.05),
              side: const BorderSide(color: Colors.blue),
              onPressed: () => _handleSystemExport(context, ref),
            ),
          ),
        ],
      ),
      body: enterprisesAsync.when(
        data: (enterprises) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricHighlights(enterprises),
              const SizedBox(height: 32),
              const Text(
                'Enterprise Progress Tracking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildEnterpriseTable(context, ref, enterprises),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMetricHighlights(List<dynamic> enterprises) {
    // Simple mock calculation for demonstration
    final total = enterprises.length;
    
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Monitoring Total',
            value: total.toString(),
            icon: Icons.business_rounded,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Health Score',
            value: '78%',
            icon: Icons.favorite_rounded,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Reporting Rate',
            value: '92%',
            icon: Icons.bar_chart_rounded,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildEnterpriseTable(BuildContext context, WidgetRef ref, List<dynamic> enterprises) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
          horizontalMargin: 20,
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Enterprise')),
            DataColumn(label: Text('Sector')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Report')),
          ],
          rows: enterprises.map((ent) {
            return DataRow(cells: [
              DataCell(Text(ent.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(ent.sector ?? 'General')),
              DataCell(_buildStatusBadge(ent.status)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.blue),
                  onPressed: () => _handlePdfExport(context, ref, ent.id),
                  tooltip: 'Generate PDF Report',
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color = Colors.grey;
    if (status == 'active') color = Colors.green;
    if (status == 'stalled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _handlePdfExport(BuildContext context, WidgetRef ref, String id) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF report...')),
      );
      await ref.read(reportDownloadProvider).downloadEnterprisePDF(id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
      );
    }
  }

  Future<void> _handleSystemExport(BuildContext context, WidgetRef ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exporting system CSV...')),
      );
      await ref.read(reportDownloadProvider).downloadSystemCSV();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    }
  }
}
