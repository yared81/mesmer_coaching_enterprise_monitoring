import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:dio/dio.dart';

final graduationReadyProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/v1/graduation/ready');
  return response.data['data'] as List;
});

class GraduationReadyScreen extends ConsumerWidget {
  const GraduationReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyAsync = ref.watch(graduationReadyProvider);

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
      body: readyAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No enterprises currently ready for graduation.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final ent = list[index];
              return _buildGraduationCard(
                context,
                id: ent['id'],
                name: ent['business_name'],
                owner: ent['owner_name'],
                location: ent['location_name'] ?? 'N/A',
                sessionCount: ent['completedCount'] ?? 0,
                coach: ent['coach']?['name'] ?? 'N/A',
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading list: $e')),
      ),
    );
  }

  Widget _buildGraduationCard(
    BuildContext context, {
    required String id,
    required String name,
    required String owner,
    required String location,
    required int sessionCount,
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
                    '$sessionCount Sessions',
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Owner: $owner | $location', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('Coach: $coach', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.successStories),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('STORY'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.certificateManagement, extra: id),
                  icon: const Icon(Icons.card_membership, size: 18),
                  label: const Text('GENERATE'),
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
