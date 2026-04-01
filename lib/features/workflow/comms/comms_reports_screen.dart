import 'package:flutter/material.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';

class CommsReportsScreen extends StatelessWidget {
  const CommsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Program Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Text('GENERATE NEW REPORT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: AppSpacing.md),
          _buildReportTypeCard(
            title: 'Quarterly Impact Report',
            description: 'Success stories, KPIs, and regional breakdown.',
            icon: Icons.analytics,
            color: Colors.blue,
          ),
          _buildReportTypeCard(
            title: 'Graduation Summary',
            description: 'List of certified enterprises and metrics.',
            icon: Icons.school,
            color: Colors.green,
          ),
          _buildReportTypeCard(
            title: 'Donor/Partner Report',
            description: 'Formatted for stakeholder presentation.',
            icon: Icons.description,
            color: Colors.orange,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('RECENT REPORTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: AppSpacing.md),
          _buildRecentReportItem(title: 'Q1 2025 Impact Report', date: 'Mar 20, 2025', size: '2.4 MB'),
          _buildRecentReportItem(title: 'Feb 2025 Graduation Summary', date: 'Mar 1, 2025', size: '1.2 MB'),
        ],
      ),
    );
  }

  Widget _buildReportTypeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {},
      ),
    );
  }

  Widget _buildRecentReportItem({required String title, required String date, required String size}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[100]!)),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        subtitle: Text('Generated: $date | $size'),
        trailing: const Icon(Icons.download, size: 18),
        onTap: () {},
      ),
    );
  }
}
