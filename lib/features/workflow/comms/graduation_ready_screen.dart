import 'package:flutter/material.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class GraduationReadyScreen extends StatelessWidget {
  const GraduationReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Graduation Ready', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Cleared by M&E for Certification', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Text('READY FOR GRADUATION (12)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: AppSpacing.md),
          _buildGraduationCard(
            context,
            name: 'ABC Hardware',
            owner: 'Ayele T.',
            location: 'Addis Ababa',
            completedDate: 'March 20, 2025',
            improvement: '+43%',
            coach: 'Alemitu T.',
          ),
          _buildGraduationCard(
            context,
            name: 'Tesfa Bakery',
            owner: 'Tigist M.',
            location: 'Addis Ababa',
            completedDate: 'March 18, 2025',
            improvement: '+44%',
            coach: 'Biruk D.',
          ),
          _buildGraduationCard(
            context,
            name: 'Kebede Traders',
            owner: 'Kebede A.',
            location: 'Addis Ababa',
            completedDate: 'March 15, 2025',
            improvement: '+41%',
            coach: 'Meron A.',
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.auto_awesome),
          label: const Text('BATCH GENERATE CERTIFICATES'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildGraduationCard(
    BuildContext context, {
    required String name,
    required String owner,
    required String location,
    required String completedDate,
    required String improvement,
    required String coach,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    improvement,
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Owner: $owner | $location', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('Completed: $completedDate', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('Coach: $coach', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.successStories),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('CREATE STORY'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.certificateManagement),
                  icon: const Icon(Icons.card_membership, size: 18),
                  label: const Text('GENERATE CERT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
