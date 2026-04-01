import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';
import 'package:mesmer_digital_coaching/features/auth/user_entity.dart';
import 'iap_provider.dart';
import 'iap_entity.dart';
import 'iap_evidence_service.dart';
import 'iap_progress_card.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';
import 'package:mesmer_digital_coaching/core/widgets/custom_toaster.dart';
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
    final authState = ref.watch(authProvider);
    final isEnterpriseUser = authState.user?.role == UserRole.enterprise;

    return iapsAsync.when(
      data: (iaps) {
        if (iaps.isEmpty) return _buildEmptyState(context, ref, isEnterpriseUser);
        final activeIap = iaps.first;
        return _buildTracker(context, ref, activeIap, isEnterpriseUser);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading IAP: $err')),
    );
  }

  // ─── empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isEnterpriseUser) {
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
          Text(isEnterpriseUser 
              ? 'Your coach hasn\'t created an action plan for you yet.' 
              : 'Create an Individual Action Plan to track coaching tasks.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          if (!isEnterpriseUser)
            ElevatedButton.icon(
              onPressed: () => _showIapBuilderDialog(context, ref),
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
      BuildContext context, WidgetRef ref, IapEntity iap, bool isEnterpriseUser) {
    
    final activeTasks = iap.tasks.where((t) => t.status == IapTaskStatus.pending).toList();
    final reviewTasks = iap.tasks.where((t) => t.status == IapTaskStatus.pending_verification).toList();
    final completedTasks = iap.tasks.where((t) => t.status == IapTaskStatus.completed).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Live progress ring card
        IapProgressCard(iapId: iap.id),
        
        // Header Row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEnterpriseUser ? 'My Action Plan' : 'Enterprise Action Plan',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              if (!isEnterpriseUser)
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
        ),

        if (activeTasks.isNotEmpty) ...[
          _buildSectionHeader('Active Tasks', Colors.orange),
          ...activeTasks.map((t) => _TaskCard(task: t, enterpriseId: enterpriseId, isEnterpriseUser: isEnterpriseUser)),
        ],

        if (reviewTasks.isNotEmpty) ...[
          _buildSectionHeader('Under Review', Colors.blue),
          ...reviewTasks.map((t) => _TaskCard(task: t, enterpriseId: enterpriseId, isEnterpriseUser: isEnterpriseUser)),
        ],

        if (completedTasks.isNotEmpty) ...[
          _buildSectionHeader('Completed', Colors.green),
          ...completedTasks.map((t) => _TaskCard(task: t, enterpriseId: enterpriseId, isEnterpriseUser: isEnterpriseUser)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey[200])),
        ],
      ),
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
  final bool isEnterpriseUser;
  const _TaskCard({required this.task, required this.enterpriseId, this.isEnterpriseUser = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadProgress = ref.watch(_uploadProgressProvider(task.id));
    final isCompleted = task.status == IapTaskStatus.completed;
    final isUnderReview = task.status == IapTaskStatus.pending_verification;
    final isOverdue = task.deadline.isBefore(DateTime.now()) && !isCompleted && !isUnderReview;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isOverdue ? Colors.red.shade200 : (isUnderReview ? Colors.blue.shade200 : Colors.grey.shade200)),
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
                  value: isCompleted || isUnderReview,
                  onChanged: (isCompleted && isEnterpriseUser) ? null : (val) => _toggleStatus(context, ref, val ?? false),
                  activeColor: isCompleted ? Colors.green : Colors.blue,
                  tristate: false,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.description,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                        if (isUnderReview)
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text('Under review by coach', style: TextStyle(fontSize: 10, color: Colors.blue, fontStyle: FontStyle.italic)),
                          ),
                      ],
                    ),
                  ),
                ),
                // Evidence action button
                IconButton(
                  tooltip: task.evidenceUrl != null ? 'View / Replace Evidence' : 'Upload Evidence',
                  icon: Icon(
                    task.evidenceUrl != null ? Icons.attach_file : Icons.upload_file,
                    color: task.evidenceUrl != null ? AppColors.primary : Colors.grey,
                  ),
                  onPressed: isCompleted && isEnterpriseUser ? null : () => _showEvidenceOptions(context, ref),
                ),
              ],
            ),

            // ── deadline ──
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 4),
              child: Row(children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}',
                  style: TextStyle(
                      fontSize: 11,
                      color: isOverdue ? Colors.red : Colors.grey[600]),
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
                    Text('${(uploadProgress * 100).toStringAsFixed(0)}% uploaded',
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),

            // ── evidence chip ──
            if (task.evidenceUrl != null && uploadProgress == null)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: Chip(
                  avatar: const Icon(Icons.check_circle, size: 14, color: Colors.green),
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
    return parts.last.length > 24 ? '…${parts.last.substring(parts.last.length - 20)}' : parts.last;
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref, bool checked) async {
    try {
      final svc = ref.read(iapEvidenceServiceProvider);
      String newStatus;

      if (isEnterpriseUser) {
        // Enterprise users toggle between 'pending' and 'pending_verification'
        newStatus = checked ? 'pending_verification' : 'pending';
      } else {
        // Coaches toggle between 'completed' and 'pending'
        newStatus = checked ? 'completed' : 'pending';
      }

      await svc.updateTaskStatus(task.id, newStatus);
      ref.invalidate(enterpriseIapsProvider(enterpriseId));
      
      if (context.mounted && isEnterpriseUser && checked) {
        CustomToaster.show(
            context: context,
            message: 'Task submitted for coach review! 🚀');
      }
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

  // ─── IAP Builder Dialog (Multi-task) ────────────────────────────────────────
  void _showIapBuilderDialog(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> builderTasks = [];
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBuilderState) => AlertDialog(
          title: const Text('IAP Builder', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Define initial tasks for this enterprise growth plan.', 
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: builderTasks.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(builderTasks[index]['description'], style: const TextStyle(fontSize: 13)),
                      subtitle: Text('Due: ${DateFormat('MMM dd').format(DateTime.parse(builderTasks[index]['deadline']))}',
                        style: const TextStyle(fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        onPressed: () => setBuilderState(() => builderTasks.removeAt(index)),
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final descCtrl = TextEditingController();
                    DateTime deadline = DateTime.now().add(const Duration(days: 14));
                    
                    await showDialog(
                      context: ctx,
                      builder: (childCtx) => StatefulBuilder(
                        builder: (childCtx, setChildState) => AlertDialog(
                          title: const Text('Add Task to Plan', style: TextStyle(fontSize: 16)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Task Description')),
                              const SizedBox(height: 12),
                              ListTile(
                                leading: const Icon(Icons.calendar_today, size: 16),
                                title: Text('Deadline: ${DateFormat('MMM dd, yyyy').format(deadline)}'),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: childCtx,
                                    initialDate: deadline,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) setChildState(() => deadline = picked);
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(childCtx), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                if (descCtrl.text.isEmpty) return;
                                setBuilderState(() {
                                  builderTasks.add({
                                    'description': descCtrl.text,
                                    'deadline': deadline.toIso8601String(),
                                    'status': 'pending'
                                  });
                                });
                                Navigator.pop(childCtx);
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('Add Initial Task'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: builderTasks.isEmpty ? null : () async {
                try {
                  final ds = ref.read(iapDataSourceProvider);
                  await ds.createIap({
                    'enterprise_id': enterpriseId,
                    'tasks': builderTasks,
                  });
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ref.invalidate(enterpriseIapsProvider(enterpriseId));
                    CustomToaster.show(context: context, message: 'IAP created successfully! 🚀');
                  }
                } catch (e) {
                  if (context.mounted) {
                    CustomToaster.show(context: context, message: 'Failed: $e', isError: true);
                  }
                }
              },
              child: const Text('Save & Activate Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
