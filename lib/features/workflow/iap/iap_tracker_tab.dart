import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'iap_provider.dart';
import 'iap_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/widgets/custom_toaster.dart';
import 'package:intl/intl.dart';

class IapTrackerTab extends ConsumerWidget {
  final String enterpriseId;
  const IapTrackerTab({super.key, required this.enterpriseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iapsAsync = ref.watch(enterpriseIapsProvider(enterpriseId));

    return iapsAsync.when(
      data: (iaps) {
        if (iaps.isEmpty) {
          return _buildEmptyState(context);
        }
        final activeIap = iaps.first;
        return _buildTracker(context, ref, activeIap);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading IAP: $err')),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Action Plan Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create an Individual Action Plan to track coaching tasks.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              CustomToaster.show(
                context: context,
                message: 'IAP Builder is under construction, please use the enterprise setup.',
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Action Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTracker(BuildContext context, WidgetRef ref, IapEntity iap) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: iap.tasks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Action Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddTaskDialog(context, ref, iap.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          );
        }
        final task = iap.tasks[index - 1];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            leading: Checkbox(
              value: task.status == IapTaskStatus.completed,
              onChanged: (val) {},
              activeColor: Colors.green,
            ),
            title: Text(
              task.description,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: task.status == IapTaskStatus.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}',
                    style: TextStyle(
                      color: task.deadline.isBefore(DateTime.now()) && task.status != IapTaskStatus.completed ? Colors.red : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing: task.evidenceUrl != null
                ? IconButton(
                    icon: const Icon(Icons.attach_file, color: AppColors.primary),
                    onPressed: () {},
                  )
                : IconButton(
                    icon: const Icon(Icons.upload_file, color: Colors.grey),
                    onPressed: () {},
                  ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref, String iapId) {
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Action Task', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (descriptionController.text.isEmpty) return;
              try {
                final ds = ref.read(iapDataSourceProvider);
                await ds.addTask(iapId, {
                  'description': descriptionController.text,
                  'deadline': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
                  'status': 'pending',
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(enterpriseIapsProvider(enterpriseId));
                  CustomToaster.show(context: context, message: 'Task added successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  CustomToaster.show(context: context, message: 'Failed to add task: $e', isError: true);
                }
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
