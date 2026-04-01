import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/theme/app_colors.dart';
import 'certificate_provider.dart';
import 'certificate_template.dart';
import 'graduation_validator.dart';

class CertificateGenerationScreen extends ConsumerStatefulWidget {
  final String enterpriseId;
  final String enterpriseName;
  final String ownerName;

  const CertificateGenerationScreen({
    super.key,
    required this.enterpriseId,
    required this.enterpriseName,
    required this.ownerName,
  });

  @override
  ConsumerState<CertificateGenerationScreen> createState() => _CertificateGenerationScreenState();
}

class _CertificateGenerationScreenState extends ConsumerState<CertificateGenerationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coachController = TextEditingController();
  final _coordinatorController = TextEditingController();
  final _achievementController = TextEditingController();
  
  List<String> _achievements = [];
  bool _isValidated = false;
  GraduationValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _validateGraduation();
  }

  @override
  void dispose() {
    _coachController.dispose();
    _coordinatorController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  Future<void> _validateGraduation() async {
    await ref.read(certificateProvider.notifier).validateGraduation(widget.enterpriseId);
    
    final certificateState = ref.read(certificateProvider);
    if (certificateState.validationResult != null) {
      setState(() {
        _validationResult = certificateState.validationResult;
        _isValidated = _validationResult!.isEligible;
      });
    }
  }

  void _addAchievement() {
    if (_achievementController.text.trim().isNotEmpty) {
      setState(() {
        _achievements.add(_achievementController.text.trim());
        _achievementController.clear();
      });
    }
  }

  void _removeAchievement(int index) {
    setState(() {
      _achievements.removeAt(index);
    });
  }

  Future<void> _generateCertificate() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(certificateProvider.notifier).generateCertificate(
      enterpriseId: widget.enterpriseId,
      enterpriseName: widget.enterpriseName,
      ownerName: widget.ownerName,
      coachName: _coachController.text.trim(),
      regionalCoordinator: _coordinatorController.text.trim(),
      achievements: _achievements,
    );

    final certificateState = ref.read(certificateProvider);
    if (certificateState.currentCertificate != null) {
      _showSuccessDialog();
    } else if (certificateState.errorMessage != null) {
      _showErrorDialog(certificateState.errorMessage!);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Certificate Generated Successfully'),
        content: const Text('The certificate has been generated and is ready for approval.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.certificateManagement);
            },
            child: const Text('View Certificates'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Generate Another'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final certificateState = ref.watch(certificateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Certificate'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: certificateState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEnterpriseInfo(),
                    const SizedBox(height: 24),
                    _buildValidationStatus(),
                    const SizedBox(height: 24),
                    if (_isValidated) ...[
                      _buildRequiredFields(),
                      const SizedBox(height: 24),
                      _buildAchievementsSection(),
                      const SizedBox(height: 24),
                      _buildGenerateButton(),
                    ] else if (_validationResult != null) ...[
                      _buildValidationErrors(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEnterpriseInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enterprise Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Enterprise Name', widget.enterpriseName),
            _buildInfoRow('Owner Name', widget.ownerName),
            _buildInfoRow('Enterprise ID', widget.enterpriseId),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    if (_validationResult == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Validating graduation requirements...'),
            ],
          ),
        ),
      );
    }

    final status = _validationResult!;
    final color = status.isEligible ? Colors.green : Colors.orange;
    final icon = status.isEligible ? Icons.check_circle : Icons.warning;

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.isEligible ? 'Ready for Certificate' : 'Not Eligible',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (status.errorMessage != null)
                    Text(
                      status.errorMessage!,
                      style: TextStyle(color: color),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationErrors() {
    if (_validationResult == null) return const SizedBox();

    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Graduation Requirements Not Met:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),
            _buildValidationItem('Baseline Assessment', _validationResult!.baselineStatus),
            _buildValidationItem('Coaching Sessions', _validationResult!.coachingStatus),
            _buildValidationItem('Midline Assessment', _validationResult!.midlineStatus),
            _buildValidationItem('Final IAP', _validationResult!.iapStatus),
            _buildValidationItem('Evidence', _validationResult!.evidenceStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationItem(String title, dynamic status) {
    final isValid = status is Map ? status['isValid'] == true : false;
    final message = status is Map ? status['message'] ?? '' : status.toString();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $message',
              style: TextStyle(
                color: isValid ? Colors.green : Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _coachController,
              decoration: const InputDecoration(
                labelText: 'Coach Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter coach name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _coordinatorController,
              decoration: const InputDecoration(
                labelText: 'Regional Coordinator Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.supervisor_account),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter regional coordinator name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Achievements (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _achievementController,
                    decoration: const InputDecoration(
                      labelText: 'Add achievement',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.star),
                    ),
                    onSubmitted: (_) => _addAchievement(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addAchievement,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_achievements.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _achievements.asMap().entries.map((entry) {
                  final index = entry.key;
                  final achievement = entry.value;
                  return Chip(
                    label: Text(achievement),
                    onDeleted: () => _removeAchievement(index),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: certificateState.isLoading ? null : _generateCertificate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: certificateState.isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Text('Generating...'),
                ],
              )
            : const Text(
                'Generate Certificate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
