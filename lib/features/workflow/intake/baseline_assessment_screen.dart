import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';
import 'package:mesmer_digital_coaching/core/db/local_database.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:mesmer_digital_coaching/core/widgets/custom_toaster.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_digital_coaching/shared/widgets/primary_button.dart';
import 'package:dio/dio.dart';

// ── Baseline questions (Finance, Marketing, Operations, Management) ──────────
const _kQuestions = {
  'Finance': [
    'Does the business keep daily sales records?',
    'Are business and personal finances separated?',
    'Does the owner know the monthly profit/loss?',
    'Is there a system for tracking expenses?',
    'Does the business have a bank account?',
    'Are invoices or receipts issued to customers?',
  ],
  'Marketing': [
    'Does the business have a defined target customer?',
    'Does the owner know the main competitors?',
    'Is there a pricing strategy in place?',
    'Does the business use any form of advertising?',
    'Does the owner collect customer feedback?',
  ],
  'Operations': [
    'Is there an inventory tracking system?',
    'Are supplier relationships documented?',
    'Is there a quality control process?',
    'Are business hours consistent and communicated?',
    'Does the business have a written process for key tasks?',
    'Is equipment maintained regularly?',
  ],
  'Management': [
    'Does the owner have a written business plan or goals?',
    'Are staff roles and responsibilities clearly defined?',
    'Does the business track employee attendance?',
    'Is there a system for resolving customer complaints?',
  ],
};

const _kChoices = ['Yes', 'No', 'Sometimes', "Don't know"];

class BaselineAssessmentScreen extends ConsumerStatefulWidget {
  final String enterpriseId;
  const BaselineAssessmentScreen({super.key, required this.enterpriseId});

  @override
  ConsumerState<BaselineAssessmentScreen> createState() =>
      _BaselineAssessmentScreenState();
}

class _BaselineAssessmentScreenState
    extends ConsumerState<BaselineAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Section 2 controllers
  final _employeesCtrl = TextEditingController();
  final _revenueCtrl = TextEditingController();
  final _recordDescCtrl = TextEditingController();
  String? _hasRecordKeeping; // 'Yes' / 'No'

  // Section 3 — question responses: "Category|Question" -> choice
  final Map<String, String> _questionResponses = {};

  // Section 4 — uploaded evidence paths
  final List<Map<String, String>> _evidence = [];

  double get _progress => _currentStep / 3;

  @override
  void dispose() {
    _employeesCtrl.dispose();
    _revenueCtrl.dispose();
    _recordDescCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _pickEvidence(String label) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (picked == null) return;
    setState(() => _evidence.add({'label': label, 'path': picked.path}));
    if (mounted) {
      CustomToaster.show(context: context, message: '$label captured ✓');
    }
  }

  Future<void> _submit(String enterpriseId) async {
    setState(() => _isSubmitting = true);

    final payload = {
      'enterprise_id': enterpriseId,
      'enumerator_id': ref.read(authProvider).user?.id ?? '',
      'baseline_employees': int.tryParse(_employeesCtrl.text) ?? 0,
      'baseline_revenue': double.tryParse(_revenueCtrl.text) ?? 0.0,
      'has_record_keeping': _hasRecordKeeping == 'Yes',
      'record_keeping_description': _recordDescCtrl.text,
      'question_responses': _questionResponses,
      'evidence_count': _evidence.length,
      'submitted_at': DateTime.now().toIso8601String(),
      'status': 'pending_qc',
    };

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/enterprises/$enterpriseId/baseline', data: payload);
      if (mounted) {
        CustomToaster.show(
            context: context,
            message: '✅ Baseline submitted for QC review');
        Navigator.of(context).pop();
      }
    } on DioException catch (_) {
      // Offline — queue for sync
      final db = ref.read(localDatabaseProvider);
      await db.enqueueSyncAction(
          'POST', 'enterprises/$enterpriseId/baseline', jsonEncode(payload));
      if (mounted) {
        CustomToaster.show(
            context: context,
            message: '📥 Saved offline — will sync when connected');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        CustomToaster.show(
            context: context,
            message: 'Submission failed: $e',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enterpriseAsync =
        ref.watch(enterpriseDetailProvider(widget.enterpriseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Baseline Assessment')),
      body: enterpriseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (enterprise) => Column(
          children: [
            _buildStepHeader(enterprise.businessName, enterprise.ownerName),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSection1(enterprise.businessName, enterprise.ownerName,
                      enterprise.location, enterprise.phone),
                  _buildSection2(),
                  _buildSection3(),
                  _buildSection4(),
                ],
              ),
            ),
            _buildBottomNav(enterprise.id),
          ],
        ),
      ),
    );
  }

  // ── Step Header ─────────────────────────────────────────────────────────────
  Widget _buildStepHeader(String name, String owner) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Owner: $owner',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Text('${(_progress * 100).toInt()}% complete',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // ── Section 1: Business Profile (read-only from entity) ─────────────────────
  Widget _buildSection1(
      String name, String owner, String location, String phone) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Section 1: Business Profile', Icons.business_center),
          const SizedBox(height: AppSpacing.md),
          _infoTile('Enterprise Name', name),
          _infoTile('Owner Name', owner),
          _infoTile('Location', location),
          _infoTile('Contact', phone),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Profile data loaded from registration',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 2: Baseline Metrics ──────────────────────────────────────────────
  Widget _buildSection2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Section 2: Baseline Metrics', Icons.analytics),
          const SizedBox(height: AppSpacing.md),
          _inputField('Number of Employees', 'e.g. 3',
              controller: _employeesCtrl,
              keyboardType: TextInputType.number),
          _inputField('Monthly Revenue (ETB)', 'e.g. 25000',
              controller: _revenueCtrl,
              keyboardType: TextInputType.number),
          const SizedBox(height: AppSpacing.md),
          const Text('Record-Keeping System',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._kChoices.take(2).map((label) => RadioListTile<String>(
                title: Text(label),
                value: label,
                groupValue: _hasRecordKeeping,
                onChanged: (v) => setState(() => _hasRecordKeeping = v),
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
              )),
          if (_hasRecordKeeping == 'Yes')
            _inputField('Describe the system', 'e.g. Sales logbook',
                controller: _recordDescCtrl),
        ],
      ),
    );
  }

  // ── Section 3: Diagnosis Questions ──────────────────────────────────────────
  Widget _buildSection3() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _sectionHeader('Section 3: Diagnosis Questions', Icons.list_alt),
        const SizedBox(height: AppSpacing.md),
        ..._kQuestions.entries.map((entry) {
          final category = entry.key;
          final questions = entry.value;
          final answered = questions
              .where((q) => _questionResponses.containsKey('$category|$q'))
              .length;
          return _categorySection(category, questions, answered);
        }),
      ],
    );
  }

  Widget _categorySection(
      String category, List<String> questions, int answered) {
    final colors = {
      'Finance': Colors.blue,
      'Marketing': Colors.orange,
      'Operations': Colors.green,
      'Management': Colors.purple,
    };
    final color = colors[category] ?? AppColors.primary;

    return ExpansionTile(
      initiallyExpanded: answered < questions.length,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withOpacity(0.12),
        child: Text('$answered/${questions.length}',
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      ),
      title: Text(category,
          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      subtitle: Text('$answered of ${questions.length} answered',
          style: const TextStyle(fontSize: 12)),
      children: questions
          .map((q) => _questionCard(category, q, color))
          .toList(),
    );
  }

  Widget _questionCard(String category, String question, Color color) {
    final key = '$category|$question';
    final selected = _questionResponses[key];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: _kChoices
                .map((choice) => ChoiceChip(
                      label: Text(choice,
                          style: const TextStyle(fontSize: 11)),
                      selected: selected == choice,
                      selectedColor: color.withOpacity(0.15),
                      onSelected: (_) =>
                          setState(() => _questionResponses[key] = choice),
                    ))
                .toList(),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  // ── Section 4: Evidence Capture ──────────────────────────────────────────────
  Widget _buildSection4() {
    final evidenceTypes = [
      {'label': 'Storefront Photo', 'icon': Icons.store},
      {'label': 'Business License', 'icon': Icons.description},
      {'label': 'Sales Record Sample', 'icon': Icons.receipt_long},
      {'label': 'Expense Record', 'icon': Icons.payments},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Section 4: Evidence Capture', Icons.camera_alt),
          const SizedBox(height: 4),
          Text('At least one photo is required for QC submission.',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: AppSpacing.md),
          ...evidenceTypes.map((e) {
            final label = e['label'] as String;
            final icon = e['icon'] as IconData;
            final captured =
                _evidence.any((ev) => ev['label'] == label);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: captured
                    ? Colors.green.withOpacity(0.05)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: captured
                        ? Colors.green.withOpacity(0.3)
                        : Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      color: captured ? Colors.green : Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: captured ? Colors.green : null)),
                  ),
                  if (captured)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20)
                  else
                    TextButton.icon(
                      onPressed: () => _pickEvidence(label),
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text('CAPTURE'),
                    ),
                ],
              ),
            );
          }),
          if (_evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('${_evidence.length} item(s) captured',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  // ── Bottom Navigation ────────────────────────────────────────────────────────
  Widget _buildBottomNav(String enterpriseId) {
    final isLast = _currentStep == 3;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('BACK'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child: PrimaryButton(
              onPressed: _isSubmitting
                  ? null
                  : isLast
                      ? () => _submit(enterpriseId)
                      : _nextStep,
              label: _isSubmitting
                  ? 'Submitting...'
                  : isLast
                      ? 'SUBMIT FOR QC'
                      : 'NEXT STEP',
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _inputField(String label, String hint,
      {TextEditingController? controller,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: (v) {},
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
