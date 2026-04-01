import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class BaselineListScreen extends ConsumerWidget {
  const BaselineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Baseline Assessment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Enterprises Pending Assessment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.assignment_turned_in, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACTIVE ASSESSMENT PROFILE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('Standard Baseline Assessment v2.1', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Text('READY FOR BASELINE (4)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: AppSpacing.md),
          _buildBaselineItem(
            context,
            name: 'Sun Coffee',
            owner: 'Hana Y.',
            location: 'Piassa',
            regDate: 'Mar 20, 2025',
          ),
          _buildBaselineItem(
            context,
            name: 'Metro Electronics',
            owner: 'Desta L.',
            location: 'Bole',
            regDate: 'Mar 21, 2025',
          ),
          _buildBaselineItem(
            context,
            name: 'Green Groceries',
            owner: 'Mulu K.',
            location: 'Merkato',
            regDate: 'Mar 18, 2025',
          ),
        ],
      ),
    );
  }

  Widget _buildBaselineItem(
    BuildContext context, {
    required String name,
    required String owner,
    required String location,
    required String regDate,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: $owner | $location', style: const TextStyle(fontSize: 13)),
            Text('Registered: $regDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => context.push(AppRoutes.intakeBaseline.replaceFirst(':id', '123')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('START TEST'),
        ),
      ),
    );
  }
}
