import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'consent_provider.dart';

class ConsentCaptureScreen extends ConsumerStatefulWidget {
  final String enterpriseId;

  const ConsentCaptureScreen({super.key, required this.enterpriseId});

  @override
  ConsumerState<ConsentCaptureScreen> createState() => _ConsentCaptureScreenState();
}

class _ConsentCaptureScreenState extends ConsumerState<ConsentCaptureScreen> {
  bool _isConsented = false;
  bool _safeguardingAcknowledged = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isConsented || !_safeguardingAcknowledged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept both consent and safeguarding terms.')),
      );
      return;
    }

    final success = await ref.read(consentSubmitProvider.notifier).submitConsent(
          enterpriseId: widget.enterpriseId,
          isConsented: _isConsented,
          safeguardingAcknowledged: _safeguardingAcknowledged,
          notes: _notesController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consent recorded successfully.')),
      );
      context.pushReplacement(AppRoutes.intakeBaseline.replaceAll(':id', widget.enterpriseId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(consentSubmitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Consent & Compliance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PARTICIPANT CONSENT FORM',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'By participating in the MESMER Coaching program, you agree to allow your business data to be collected for the purpose of monitoring growth, graduation assessment, and program evaluation. All personal identifiable information (PII) will be handled securely according to data privacy standards.',
              style: TextStyle(height: 1.5, color: Colors.blueGrey),
            ),
            const Divider(height: 32),
            CheckboxListTile(
              value: _isConsented,
              onChanged: (val) => setState(() => _isConsented = val ?? false),
              title: const Text('I consent to participate in the MESMER Program'),
              subtitle: const Text('Includes data collection and regular coaching visits'),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              value: _safeguardingAcknowledged,
              onChanged: (val) => setState(() => _safeguardingAcknowledged = val ?? false),
              title: const Text('I acknowledge the Safeguarding Policy'),
              subtitle: const Text('I understand the program\'s code of conduct and reporting channels'),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Additional Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any specific remarks or conditions...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl * 2),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: submitState.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SUBMIT CONSENT & PROCEED', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
