import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'iap_provider.dart';
import 'iap_entity.dart';
import 'iap_evidence_service.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/widgets/custom_toaster.dart';
import 'package:intl/intl.dart';

// ─── per-task upload-progress state ───────────────────────────────────────────
final _uploadProgressProvider =
    StateProvider.family<double?, String>((ref, _) => null);

class IapTrackerTab extends ConsumerWidget {
  final String enterpriseId;
  const IapTrackerTab({super.key, required this.enterpriseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iapsAsync = ref.watch(enterpriseIapsProvider(enterpriseId));

    return iapsAsync.when(
      data: (iaps) {
        if (iaps.isEmpty) return _buildEmptyState(context, ref);
        final activeIap = iaps.first;
        return _buildTracker(context, ref, activeIap);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading IAP: $err')),
    );
  }

  // ─── empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No Action Plan Found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600])),
          const SizedBox(height: 8),
          const Text('Create an Individual Action Plan to track coaching tasks.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => CustomToaster.show(
                context: context,
                message: 'IAP Builder is under construction.'),
            icon: const Icon(Icons.add),
            label: const Text('Create Action Plan'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // ─── tracker list ────────────────────────────────────────────────────────────
  Widget _buildTracker(
      BuildContext context, WidgetRef ref, IapEntity iap) {
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
                const Text('Current Action Plan',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAddTaskDialog(context, ref, iap.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        }
        final task = iap.tasks[index - 1];
        return _TaskCard(task: task, enterpriseId: enterpriseId);
      },
    );
  }

  // ─── add-task dialog ─────────────────────────────────────────────────────────
  void _showAddTaskDialog(
      BuildContext context, WidgetRef ref, String iapId) {
    final descCtrl = TextEditingController();
    DateTime deadline =
        DateTime.now().add(const Duration(days: 14));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Action Task',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration:
                    const InputDecoration(labelText: 'Task Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Due: ${DateFormat('MMM dd, yyyy').format(deadline)}',
                    style: const TextStyle(fontSize: 12)),
                const Spacer(),
                TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                          context: ctx,
                          initialDate: deadline,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365)));
                      if (picked != null)
                        setState(() => deadline = picked);
                    },
                    child: const Text('Change')),
              ]),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (descCtrl.text.isEmpty) return;
                try {
                  final ds = ref.read(iapDataSourceProvider);
                  await ds.addTask(iapId, {
                    'description': descCtrl.text,
                    'deadline': deadline.toIso8601String(),
                    'status': 'pending',
                  });
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ref.invalidate(
                        enterpriseIapsProvider(enterpriseId));
                    CustomToaster.show(
                        context: context,
                        message: 'Task added successfully');
                  }
                } catch (e) {
                  if (context.mounted) {
                    CustomToaster.show(
                        context: context,
                        message: 'Failed: $e',
                        isError: true);
                  }
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Single task card ─────────────────────────────────────────────────────────
class _TaskCard extends ConsumerWidget {
  final IapTaskEntity task;
  final String enterpriseId;
  const _TaskCard({required this.task, required this.enterpriseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadProgress = ref.watch(_uploadProgressProvider(task.id));
    final isCompleted = task.status == IapTaskStatus.completed;
    final isOverdue = task.deadline.isBefore(DateTime.now()) && !isCompleted;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isOverdue
                ? Colors.red.shade200
                : Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── title row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (val) =>
                      _toggleStatus(context, ref, val ?? false),
                  activeColor: Colors.green,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      task.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),
                // Evidence action button
                IconButton(
                  tooltip: task.evidenceUrl != null
                      ? 'View / Replace Evidence'
                      : 'Upload Evidence',
                  icon: Icon(
                    task.evidenceUrl != null
                        ? Icons.attach_file
                        : Icons.upload_file,
                    color: task.evidenceUrl != null
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                  onPressed: () =>
                      _showEvidenceOptions(context, ref),
                ),
              ],
            ),

            // ── deadline ──
            Padding(
              padding:
                  const EdgeInsets.only(left: 48, bottom: 4),
              child: Row(children: [
                const Icon(Icons.calendar_today,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}',
                  style: TextStyle(
                      fontSize: 11,
                      color: isOverdue
                          ? Colors.red
                          : Colors.grey[600]),
                ),
              ]),
            ),

            // ── upload progress bar ──
            if (uploadProgress != null)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: uploadProgress),
                    const SizedBox(height: 2),
                    Text(
                        '${(uploadProgress * 100).toStringAsFixed(0)}% uploaded',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),

            // ── evidence chip ──
            if (task.evidenceUrl != null && uploadProgress == null)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: Chip(
                  avatar: const Icon(Icons.check_circle,
                      size: 14, color: Colors.green),
                  label: Text(
                    _shortenUrl(task.evidenceUrl!),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.green.shade50,
                  side: BorderSide(color: Colors.green.shade100),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _shortenUrl(String url) {
    final parts = url.split('/');
    return parts.last.length > 24
        ? '…${parts.last.substring(parts.last.length - 20)}'
        : parts.last;
  }

  Future<void> _toggleStatus(
      BuildContext context, WidgetRef ref, bool completed) async {
    try {
      final svc = ref.read(iapEvidenceServiceProvider);
      await svc.updateTaskStatus(
          task.id, completed ? 'completed' : 'pending');
      ref.invalidate(enterpriseIapsProvider(enterpriseId));
    } catch (e) {
      if (context.mounted) {
        CustomToaster.show(
            context: context,
            message: 'Failed to update status: $e',
            isError: true);
      }
    }
  }

  void _showEvidenceOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Upload Evidence',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.teal),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(ctx);
              _pickAndUpload(context, ref,
                  source: ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
            title: const Text('Choose From Gallery'),
            onTap: () {
              Navigator.pop(ctx);
              _pickAndUpload(context, ref,
                  source: ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file,
                color: Colors.orange),
            title: const Text('Upload Document (PDF)'),
            onTap: () {
              Navigator.pop(ctx);
              _pickDocument(context, ref);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref, {
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: source, imageQuality: 80);
    if (picked == null) return;
    await _doUpload(context, ref, picked.path);
  }

  Future<void> _pickDocument(
      BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null)
      return;
    await _doUpload(context, ref, result.files.single.path!);
  }

  Future<void> _doUpload(
      BuildContext context, WidgetRef ref, String path) async {
    final svc = ref.read(iapEvidenceServiceProvider);
    final progressNotifier =
        ref.read(_uploadProgressProvider(task.id).notifier);
    progressNotifier.state = 0.0;

    try {
      await svc.uploadEvidence(
        taskId: task.id,
        filePath: path,
        onProgress: (sent, total) {
          if (total > 0) {
            progressNotifier.state = sent / total;
          }
        },
      );
      progressNotifier.state = null;
      ref.invalidate(enterpriseIapsProvider(enterpriseId));
      if (context.mounted) {
        CustomToaster.show(
            context: context,
            message: '✅ Evidence uploaded');
      }
    } catch (e) {
      progressNotifier.state = null;
      if (context.mounted) {
        CustomToaster.show(
            context: context,
            message: 'Upload failed: $e',
            isError: true);
      }
    }
  }
}
