import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/domain/entities/coaching_session_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/providers/coaching_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/providers/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/diagnosis/presentation/providers/diagnosis_provider.dart';

/// A lighter session creation sheet that pre-selects the enterprise.
/// Designed to be shown as a modal bottom sheet from the EnterpriseDetailScreen.
class AddSessionFromEnterpriseSheet extends ConsumerStatefulWidget {
  final String enterpriseId;
  const AddSessionFromEnterpriseSheet({super.key, required this.enterpriseId});

  @override
  ConsumerState<AddSessionFromEnterpriseSheet> createState() =>
      _AddSessionFromEnterpriseSheetState();
}

class _AddSessionFromEnterpriseSheetState
    extends ConsumerState<AddSessionFromEnterpriseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedTemplateId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final session = CoachingSessionEntity(
      id: '',
      title: _titleController.text.trim(),
      enterpriseId: widget.enterpriseId,
      templateId: _selectedTemplateId,
      coachId: user.id,
      scheduledDate: _selectedDate,
      status: SessionStatus.scheduled,
      notes: '',
      problemsIdentified: '',
      recommendations: '',
    );

    try {
      await ref.read(coachingSessionsProvider.notifier).createSession(session);
      // Invalidate the enterprise's session cache so timeline refreshes
      ref.invalidate(enterpriseSessionsProvider(widget.enterpriseId));
      ref.invalidate(coachingSessionsProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create session: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'New Coaching Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Recording a new session for this enterprise.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              autofocus: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Please enter a session title' : null,
              decoration: InputDecoration(
                labelText: 'Session Title',
                hintText: 'e.g. Initial Assessment, Follow-up Review...',
                prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF3D5AFE)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3D5AFE), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Assessment Profile Dropdown
            const Text(
              'Assessment Profile',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            ref.watch(allTemplatesProvider).when(
              data: (list) => DropdownButtonFormField<String>(
                value: _selectedTemplateId,
                decoration: InputDecoration(
                  hintText: 'Select Assessment Tool',
                  prefixIcon: const Icon(Icons.assessment_outlined, color: Color(0xFF3D5AFE)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: list.map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.title),
                )).toList(),
                onChanged: (val) => setState(() => _selectedTemplateId = val),
                validator: (val) => val == null ? 'Please select a profile' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading profiles: $err', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),

            // Date picker
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: Color(0xFF3D5AFE), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Create Session',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
