import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';
import 'graduation_provider.dart';
import 'enterprise_provider.dart';
import 'package:mesmer_digital_coaching/core/widgets/custom_toaster.dart';

class GraduationHubScreen extends ConsumerWidget {
  const GraduationHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyListAsync = ref.watch(graduationReadyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graduation Hub'),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
      ),
      body: readyListAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No enterprises ready for graduation at the moment.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(graduationReadyListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(item['business_name'] ?? 'Unknown Business', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Owner: ${item['owner_name'] ?? "N/A"}'),
                        Text('Sessions Completed: ${item['completedCount'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _approveGraduation(context, ref, item['id']),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Approve'),
                    ),
                    onTap: () {
                      context.push(AppRoutes.enterpriseDetail(item['id']));
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error loading data: $error')),
      ),
    );
  }

  Future<void> _approveGraduation(BuildContext context, WidgetRef ref, String enterpriseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Graduation'),
        content: const Text('Officially graduate this enterprise? This action generates the certificate and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Approve Graduation')
          ),
        ],
      )
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = ref.read(graduationRepositoryProvider);
        final result = await repo.requestGraduation(enterpriseId);
        result.fold(
          (failure) {
            if (context.mounted) CustomToaster.show(context: context, message: failure.message, isError: true);
          },
          (data) {
             if (context.mounted) CustomToaster.show(context: context, message: 'Graduation successfully approved!');
             ref.invalidate(graduationReadyListProvider);
             ref.invalidate(enterpriseDetailProvider(enterpriseId));
             ref.invalidate(enterpriseListProvider);
          }
        );
      } catch (e) {
         if (context.mounted) CustomToaster.show(context: context, message: 'Unexpected Error: $e', isError: true);
      }
    }
  }
}
