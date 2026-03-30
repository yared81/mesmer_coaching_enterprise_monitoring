import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class IntakeQueueScreen extends ConsumerWidget {
  const IntakeQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Intake Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Pending Registration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {}, // Import CSV
            tooltip: 'Import CSV',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'PENDING OUTREACH (8)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildEnterpriseCard(
              context,
              name: 'ABC Hardware',
              owner: 'Ayele T.',
              location: 'Bole',
              phone: '+251 911 234 567',
              status: 'Not contacted',
            ),
            _buildEnterpriseCard(
              context,
              name: 'Tesfa Bakery',
              owner: 'Tigist M.',
              location: 'Piassa',
              phone: '+251 922 345 678',
              status: 'Not contacted',
            ),
            _buildEnterpriseCard(
              context,
              name: 'Kebede Traders',
              owner: 'Kebede A.',
              location: 'Merkato',
              phone: '+251 933 456 789',
              status: 'Not contacted',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.intakeRegister),
        label: const Text('New Enterprise'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alemitu Tadesse', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'Region: Addis Ababa',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnterpriseCard(
    BuildContext context, {
    required String name,
    required String owner,
    required String location,
    required String phone,
    required String status,
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
                const Icon(Icons.phone_outlined, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Owner: $owner | $location', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text('Phone: $phone', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Starting call to $phone...')),
                    );
                  },
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('CALL'),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logging visit attempt for $name...')),
                    );
                  },
                  icon: const Icon(Icons.directions_walk, size: 16),
                  label: const Text('VISIT'),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
