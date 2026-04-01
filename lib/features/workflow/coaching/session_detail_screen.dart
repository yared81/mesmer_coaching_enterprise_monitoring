import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';
import 'coaching_session_entity.dart';
import 'coaching_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/diagnosis/diagnosis_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesmer_digital_coaching/core/widgets/custom_toaster.dart';
import 'package:mesmer_digital_coaching/features/workflow/enterprise/enterprise_document_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/iap/iap_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/iap/iap_entity.dart';
import 'package:mesmer_digital_coaching/core/theme/app_colors.dart';
import 'package:mesmer_digital_coaching/core/widgets/signature_pad_widget.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final CoachingSessionEntity session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  late TextEditingController _problemsController;
  late TextEditingController _recommendationsController;
  late TextEditingController _notesController;
  late TextEditingController _revenueController;
  late TextEditingController _employeesController;
  bool _isSaving = false;
  String? _coachSignatureBase64;
  String? _enterpriseSignatureBase64;

  @override
  void initState() {
    super.initState();
    _problemsController = TextEditingController(text: widget.session.problemsIdentified);
    _recommendationsController = TextEditingController(text: widget.session.recommendations);
    _notesController = TextEditingController(text: widget.session.notes);
    _revenueController = TextEditingController(text: widget.session.revenueGrowthPercent.toString());
    _employeesController = TextEditingController(text: widget.session.currentEmployees.toString());
  }

  @override
  void dispose() {
    _problemsController.dispose();
    _recommendationsController.dispose();
    _notesController.dispose();
    _revenueController.dispose();
    _employeesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes({bool isFinalizing = false}) async {
    setState(() => _isSaving = true);
    
    final updatedSession = CoachingSessionEntity(
      id: widget.session.id,
      title: widget.session.title,
      enterpriseId: widget.session.enterpriseId,
      coachId: widget.session.coachId,
      scheduledDate: widget.session.scheduledDate,
      status: isFinalizing ? SessionStatus.completed : widget.session.status,
      sessionNumber: widget.session.sessionNumber,
      followupType: widget.session.followupType,
      revenueGrowthPercent: double.tryParse(_revenueController.text) ?? 0.0,
      currentEmployees: int.tryParse(_employeesController.text) ?? 0,
      jobsCreated: widget.session.jobsCreated, // Typically calculated or manual, keep for now
      qcStatus: widget.session.qcStatus,
      problemsIdentified: _problemsController.text,
      recommendations: _recommendationsController.text,
      notes: _notesController.text,
      templateId: widget.session.templateId,
      coachSignature: _coachSignatureBase64 ?? widget.session.coachSignature,
      enterpriseSignature: _enterpriseSignatureBase64 ?? widget.session.enterpriseSignature,
    );

    try {
      await ref.read(coachingSessionsProvider.notifier).updateSession(updatedSession);
      
      // Force refresh the specific enterprise's session list and the single session
      ref.invalidate(enterpriseSessionsProvider(widget.session.enterpriseId));
      ref.invalidate(coachingSessionProvider(widget.session.id));
      
      if (mounted) {
        setState(() => _isSaving = false);
        CustomToaster.show(
          context: context,
          message: isFinalizing ? 'Session finalized successfully' : 'Notes saved successfully',
        );
        if (isFinalizing) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        CustomToaster.show(
          context: context,
          message: 'Failed to save session. Please try again.',
          isError: true,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final hoursSinceScheduled = DateTime.now().difference(widget.session.scheduledDate).inHours;
    final isLocked48Hours = hoursSinceScheduled > 48;
    final isReadOnly = widget.session.status == SessionStatus.completed || isLocked48Hours;
    final diagnosisReportAsync = ref.watch(existingDiagnosisReportProvider(widget.session.id));
    final hasDiagnosis = diagnosisReportAsync.valueOrNull != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Session Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!isReadOnly)
            TextButton(
              onPressed: _isSaving ? null : () => _saveNotes(),
              child: Text(
                'SAVE DRAFT',
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(widget.session.scheduledDate),
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isReadOnly ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isReadOnly ? Colors.green : Colors.orange),
                  ),
                  child: Text(
                    isReadOnly ? 'COMPLETED' : 'IN PROGRESS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isReadOnly ? Colors.green : Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 48-Hour Lock Badge
            if (isLocked48Hours && widget.session.status != SessionStatus.completed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Locked (48-hour rule). Contact verifier for edits.',
                      style: TextStyle(color: Colors.amber.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Supervisor QC Feedback Section
            if (widget.session.qcStatus == QcStatus.flagged || 
                widget.session.qcStatus == QcStatus.audited_fail || 
                (widget.session.qcFeedback?.isNotEmpty ?? false)) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
                        const SizedBox(width: 8),
                        const Text('Supervisor Feedback - Action Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFDC2626))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.session.qcFeedback ?? 'Session flagged by supervisor. Please review and update.',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Editable Notes Section
            const Text('Observations & Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            
            _buildNoteField('Problems Identified', _problemsController, readOnly: isReadOnly),
            const SizedBox(height: 20),
            _buildNoteField('Recommendations', _recommendationsController, readOnly: isReadOnly),
            const SizedBox(height: 20),
            _buildNoteField('General Notes', _notesController, maxLines: 5, readOnly: isReadOnly),
            const SizedBox(height: 32),

            // Growth Metrics Section (New Phase 3)
            if (widget.session.followupType == FollowupType.physical) ...[
              const Text('Growth Metrics (Mandatory)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    _buildMetricField('Revenue Growth %', _revenueController, Icons.trending_up, isReadOnly),
                    const SizedBox(height: 16),
                    _buildMetricField('Current Employee Count', _employeesController, Icons.people_outline, isReadOnly),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Action Plan Integration (New Phase 3)
            const Text('Action Plan Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildActionPlanSection(),
            const SizedBox(height: 32),
            
            // Attachments Section
            const Text('Attachments & Evidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (!isReadOnly)
              OutlinedButton.icon(
                onPressed: () {
                  final path = AppRoutes.evidenceUpload
                      .replaceAll(':sessionId', widget.session.id)
                      .replaceAll(':enterpriseId', widget.session.enterpriseId);
                  context.push(path);
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Photo / Document'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const SizedBox(height: 8),
            _buildAttachmentsGallery(),

            const SizedBox(height: 32),

            // ─── SIGNATURES SECTION ───
            if (!isReadOnly && widget.session.followupType == FollowupType.physical) ...[
              const Text('Digital Sign-off', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              SignaturePadWidget(
                title: 'Coach Signature',
                onSave: (base64) => setState(() => _coachSignatureBase64 = base64),
              ),
              const SizedBox(height: 16),
              SignaturePadWidget(
                title: 'Enterprise Owner Signature',
                onSave: (base64) => setState(() => _enterpriseSignatureBase64 = base64),
              ),
              const SizedBox(height: 32),
            ],

            const SizedBox(height: 32),

            // ─── ACTION BUTTONS ───
            if (!isReadOnly) ...[
              const Divider(),
              const SizedBox(height: 16),

              // Diagnosis status indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasDiagnosis ? Colors.green.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: hasDiagnosis ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasDiagnosis ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                      color: hasDiagnosis ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasDiagnosis ? 'Diagnosis assessment completed ✓' : 'Diagnosis assessment not yet completed',
                        style: TextStyle(
                          color: hasDiagnosis ? Colors.green.shade700 : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.diagnosis, extra: widget.session.id);
                  },
                  icon: const Icon(Icons.analytics_outlined),
                  label: Text(
                    hasDiagnosis ? 'VIEW / UPDATE DIAGNOSIS' : 'ASSESS & DIAGNOSE',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () {
                    // Check diagnosis first
                    if (!hasDiagnosis) {
                      CustomToaster.show(
                        context: context,
                        message: 'Complete the diagnosis assessment first before finalizing.',
                        isError: true,
                      );
                      return;
                    }
                    // Check session detail fields
                    if (_problemsController.text.isEmpty || _recommendationsController.text.isEmpty) {
                      CustomToaster.show(
                        context: context,
                        message: 'Please fill in Problems and Recommendations before finalizing.',
                        isError: true,
                      );
                      return;
                    }
                    // Check signatures for physical sessions
                    if (widget.session.followupType == FollowupType.physical) {
                      if (_coachSignatureBase64 == null && widget.session.coachSignature == null) {
                        CustomToaster.show(
                          context: context,
                          message: 'Coach signature is required for physical visits.',
                          isError: true,
                        );
                        return;
                      }
                      if (_enterpriseSignatureBase64 == null && widget.session.enterpriseSignature == null) {
                        CustomToaster.show(
                          context: context,
                          message: 'Enterprise owner signature is required for physical visits.',
                          isError: true,
                        );
                        return;
                      }
                    }
                    _saveNotes(isFinalizing: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor: Theme.of(context).disabledColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('FINALIZE SESSION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
                ),
              ),
            ] else 
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.diagnosis, extra: widget.session.id);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('VIEW ASSESSMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField(String label, TextEditingController controller, {int maxLines = 3, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: !readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsGallery() {
    final docsAsync = ref.watch(sessionDocumentsProvider(widget.session.id));
    return docsAsync.when(
      data: (docs) {
        if (docs.isEmpty) {
          return const Text('No attachments yet.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: docs.map((d) => Chip(
            avatar: const Icon(Icons.image, size: 16),
            label: Text(d.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
            onDeleted: widget.session.status == SessionStatus.completed 
              ? null 
              : () async {
                final repo = ref.read(enterpriseDocumentRepositoryProvider);
                await repo.deleteDocument(d.id);
                ref.invalidate(sessionDocumentsProvider(widget.session.id));
                ref.invalidate(enterpriseDocumentsProvider(widget.session.enterpriseId));
              },
          )).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, st) => const Text('No attachments yet.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildMetricField(String label, TextEditingController controller, IconData icon, bool readOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).hintColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          enabled: !readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary, size: 20),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
          ),
        ),
      ],
    );
  }

  Widget _buildActionPlanSection() {
    final iapsAsync = ref.watch(enterpriseIapsProvider(widget.session.enterpriseId));
    
    return iapsAsync.when(
      data: (iaps) {
        if (iaps.isEmpty) return const Text('No active action plan found.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
        final tasks = iaps.first.tasks;
        if (tasks.isEmpty) return const Text('No tasks created yet.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
        
        return Column(
          children: tasks.map((task) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), 
              side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            child: ListTile(
              dense: true,
              leading: Checkbox(
                value: task.status == IapTaskStatus.completed,
                onChanged: widget.session.status == SessionStatus.completed ? null : (val) {
                  // In a real app, update task status via provider
                  CustomToaster.show(context: context, message: 'Task status updated locally (Demo)');
                },
              ),
              title: Text(task.description, style: TextStyle(
                fontSize: 13, 
                decoration: task.status == IapTaskStatus.completed ? TextDecoration.lineThrough : null
              )),
              subtitle: Text('Due: ${DateFormat('MMM dd').format(task.deadline)}', style: const TextStyle(fontSize: 11)),
            ),
          )).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => const Text('Failed to load tasks.'),
    );
  }
}
