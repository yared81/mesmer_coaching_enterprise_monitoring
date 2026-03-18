import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'coaching_session_entity.dart';
import 'coaching_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/diagnosis_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/widgets/custom_toaster.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_document_provider.dart';

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
  bool _isSaving = false;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _problemsController = TextEditingController(text: widget.session.problemsIdentified);
    _recommendationsController = TextEditingController(text: widget.session.recommendations);
    _notesController = TextEditingController(text: widget.session.notes);
  }

  @override
  void dispose() {
    _problemsController.dispose();
    _recommendationsController.dispose();
    _notesController.dispose();
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
      problemsIdentified: _problemsController.text,
      recommendations: _recommendationsController.text,
      notes: _notesController.text,
      templateId: widget.session.templateId,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save session. Please try again.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    
    setState(() => _isUploading = true);
    
    try {
      final repo = ref.read(enterpriseDocumentRepositoryProvider);
      final result = await repo.uploadDocument(
        enterpriseId: widget.session.enterpriseId,
        sessionId: widget.session.id,
        fileName: image.name,
        fileUrl: image.path, // For hackathon, just using local path. Ideally send to S3
        fileType: 'image/jpeg',
      );
      
      if (mounted) {
        setState(() => _isUploading = false);
        result.fold(
          (failure) => CustomToaster.show(context: context, message: failure.message, isError: true),
          (success) {
            CustomToaster.show(context: context, message: 'Attachment uploaded automatically');
            // Refresh list
            ref.invalidate(sessionDocumentsProvider(widget.session.id));
            ref.invalidate(enterpriseDocumentsProvider(widget.session.enterpriseId));
          }
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        CustomToaster.show(context: context, message: 'Upload failed.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.session.status == SessionStatus.completed;
    final diagnosisReportAsync = ref.watch(existingDiagnosisReportProvider(widget.session.id));
    final hasDiagnosis = diagnosisReportAsync.valueOrNull != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Session Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isReadOnly)
            TextButton(
              onPressed: _isSaving ? null : () => _saveNotes(),
              child: const Text('SAVE DRAFT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3D5AFE)),
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
                    color: (isReadOnly ? Colors.green : Colors.orange).withOpacity(0.1),
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
            const SizedBox(height: 32),
            
            // Editable Notes Section
            const Text('Observations & Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            
            _buildNoteField('Problems Identified', _problemsController, readOnly: isReadOnly),
            const SizedBox(height: 20),
            _buildNoteField('Recommendations', _recommendationsController, readOnly: isReadOnly),
            const SizedBox(height: 20),
            _buildNoteField('General Notes', _notesController, maxLines: 5, readOnly: isReadOnly),
            const SizedBox(height: 24),
            
            // Attachments Section
            const Text('Attachments & Evidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (!isReadOnly)
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: _isUploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_photo_alternate_outlined),
                label: Text(_isUploading ? 'Uploading...' : 'Add Photo / Document'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const SizedBox(height: 8),
            _buildAttachmentsGallery(),

            const SizedBox(height: 32),

            // ─── ACTION BUTTONS ───
            if (!isReadOnly) ...[
              const Divider(),
              const SizedBox(height: 16),

              // Diagnosis status indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasDiagnosis ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: hasDiagnosis ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
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
                          color: hasDiagnosis ? Colors.green[800] : Colors.orange[800],
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
                    foregroundColor: const Color(0xFF3D5AFE),
                    side: const BorderSide(color: Color(0xFF3D5AFE), width: 2),
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
                    _saveNotes(isFinalizing: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF3D5AFE))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: !readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? Colors.grey[50] : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
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
}
