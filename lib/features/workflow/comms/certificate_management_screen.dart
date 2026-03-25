import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/widgets/custom_toaster.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/graduation_provider.dart';
import 'package:printing/printing.dart';
import 'certificate_service.dart';

class CertificateManagementScreen extends ConsumerStatefulWidget {
  final String? enterpriseId;
  const CertificateManagementScreen({super.key, this.enterpriseId});

  @override
  ConsumerState<CertificateManagementScreen> createState() => _CertificateManagementScreenState();
}

class _CertificateManagementScreenState extends ConsumerState<CertificateManagementScreen> {
  bool _isGraduating = false;

  Future<void> _handleGraduation(String enterpriseId) async {
    setState(() => _isGraduating = true);
    
    final graduationNotifier = ref.read(graduationProvider.notifier);
    await graduationNotifier.request(enterpriseId);
    
    if (mounted) {
      final state = ref.read(graduationProvider);
      state.when(
        data: (data) {
          setState(() => _isGraduating = false);
          CustomToaster.show(context: context, message: 'Enterprise successfully graduated!');
          ref.invalidate(enterpriseDetailProvider(enterpriseId));
          ref.invalidate(enterpriseListProvider);
          // Navigator.pop(context);
        },
        loading: () {},
        error: (e, st) {
          setState(() => _isGraduating = false);
          CustomToaster.show(context: context, message: 'Graduation failed: $e', isError: true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Certificate Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: widget.enterpriseId == null 
        ? _buildEmptyState()
        : _buildGeneratorView(widget.enterpriseId!),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Please select an enterprise from the Graduation Ready list.'));
  }

  Widget _buildGeneratorView(String enterpriseId) {
    final enterpriseAsync = ref.watch(enterpriseDetailProvider(enterpriseId));

    return enterpriseAsync.when(
      data: (enterprise) {
        if (enterprise == null) return const Center(child: Text('Enterprise not found.'));
        
        return Column(
          children: [
            Expanded(
              child: PdfPreview(
                build: (format) => CertificateService.generateGraduationCertificate(
                  enterprise: enterprise,
                  verificationCode: 'PREVIEW-ONLY',
                  coachName: 'Assigned Coach',
                ),
                allowPrinting: true,
                allowSharing: true,
                canChangePageFormat: false,
                loadingWidget: const Center(child: CircularProgressIndicator()),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isGraduating ? null : () => _handleGraduation(enterpriseId),
                  icon: _isGraduating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.verified),
                  label: Text(_isGraduating ? 'PROCESSING...' : 'COMMIT GRADUATION'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
