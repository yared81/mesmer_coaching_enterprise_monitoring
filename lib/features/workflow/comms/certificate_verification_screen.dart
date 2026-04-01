import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/theme/app_colors.dart';
import 'certificate_provider.dart';
import 'certificate_template.dart';
import 'certificate_verification.dart';

class CertificateVerificationScreen extends ConsumerStatefulWidget {
  const CertificateVerificationScreen({super.key});

  @override
  ConsumerState<CertificateVerificationScreen> createState() => _CertificateVerificationScreenState();
}

class _CertificateVerificationScreenState extends ConsumerState<CertificateVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  CertificateTemplate? _verifiedCertificate;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCertificate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _verifiedCertificate = null;
    });

    try {
      final certificate = await ref.read(certificateProvider.notifier)
          .verifyCertificate(_codeController.text.trim().toUpperCase());
      
      setState(() {
        _isVerifying = false;
        _verifiedCertificate = certificate;
        if (certificate == null) {
          _errorMessage = 'Certificate not found or invalid verification code';
        }
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Verification failed: $e';
      });
    }
  }

  void _resetVerification() {
    setState(() {
      _codeController.clear();
      _verifiedCertificate = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Verification'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildVerificationForm(),
            const SizedBox(height: 24),
            if (_isVerifying)
              const Center(child: CircularProgressIndicator())
            else if (_verifiedCertificate != null)
              _buildCertificateDetails()
            else if (_errorMessage != null)
              _buildErrorMessage(),
            const SizedBox(height: 24),
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Verification Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the 12-character verification code from the certificate',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified),
                  helperText: 'Format: ABCD1234EFGH',
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter verification code';
                  }
                  if (value.trim().length != 12) {
                    return 'Verification code must be 12 characters';
                  }
                  if (!CertificateVerificationService.isValidVerificationCode(value.trim())) {
                    return 'Invalid verification code format';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _verifyCertificate(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyCertificate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Verify Certificate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _resetVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateDetails() {
    final certificate = _verifiedCertificate!;
    
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Certificate Verified',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Certificate Number', certificate.certificateNumber ?? 'N/A'),
            _buildDetailRow('Enterprise Name', certificate.enterpriseName),
            _buildDetailRow('Owner Name', certificate.ownerName),
            _buildDetailRow('Program', certificate.programName),
            _buildDetailRow('Issue Date', _formatDate(certificate.issueDate)),
            _buildDetailRow('Completion Date', _formatDate(certificate.completionDate)),
            _buildDetailRow('Coach', certificate.coachName),
            _buildDetailRow('Regional Coordinator', certificate.regionalCoordinator),
            _buildDetailRow('Status', _formatStatus(certificate.status)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security Information',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Verification Code', certificate.verificationCode),
                  _buildDetailRow('Certificate ID', certificate.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Verify a Certificate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '1',
              'Locate the 12-character verification code on the certificate',
            ),
            _buildInstructionStep(
              '2',
              'Enter the code in the field above (case-insensitive)',
            ),
            _buildInstructionStep(
              '3',
              'Click "Verify Certificate" to validate',
            ),
            _buildInstructionStep(
              '4',
              'View certificate details if verification is successful',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verification codes are unique to each certificate and cannot be reused.',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatStatus(CertificateStatus status) {
    switch (status) {
      case CertificateStatus.pending:
        return 'Pending Approval';
      case CertificateStatus.approved:
        return 'Approved';
      case CertificateStatus.issued:
        return 'Issued';
      case CertificateStatus.revoked:
        return 'Revoked';
    }
  }
}
