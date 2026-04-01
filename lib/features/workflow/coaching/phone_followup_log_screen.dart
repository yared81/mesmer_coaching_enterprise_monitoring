import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';
import 'package:mesmer_digital_coaching/core/widgets/custom_toaster.dart';
import 'coaching_provider.dart';
import 'phone_followup_entity.dart';

class PhoneFollowupLogScreen extends ConsumerStatefulWidget {
  final String enterpriseId;
  const PhoneFollowupLogScreen({super.key, required this.enterpriseId});

  @override
  ConsumerState<PhoneFollowupLogScreen> createState() => _PhoneFollowupLogScreenState();
}

class _PhoneFollowupLogScreenState extends ConsumerState<PhoneFollowupLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _issueController = TextEditingController();
  final _adviceController = TextEditingController();
  final _nextActionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _purposeController.dispose();
    _issueController.dispose();
    _adviceController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    try {
      final log = PhoneFollowupEntity(
        id: '', // Backend generates UUID
        enterpriseId: widget.enterpriseId,
        coachId: '', // Backend uses req.user.id
        date: DateTime.now(),
        purpose: _purposeController.text,
        issueAddressed: _issueController.text,
        adviceGiven: _adviceController.text,
        nextAction: _nextActionController.text,
      );

      await ref.read(phoneFollowupListProvider.notifier).createLog(log);
      
      if (mounted) {
        CustomToaster.show(context: context, message: 'Phone call logged successfully');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        CustomToaster.show(context: context, message: 'Failed to log call: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Log Phone Call'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Call Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                label: 'Purpose of Call',
                controller: _purposeController,
                hint: 'e.g. Weekly check-in, Issue resolution',
                validator: (val) => val == null || val.isEmpty ? 'Purpose is required' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Issue Addressed',
                controller: _issueController,
                hint: 'What was the main topic discussed?',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Advice Given',
                controller: _adviceController,
                hint: 'What recommendations did you provide?',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Next Actions',
                controller: _nextActionController,
                hint: 'What are the next steps for the owner?',
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
          ),
        ),
      ],
    );
  }
}
