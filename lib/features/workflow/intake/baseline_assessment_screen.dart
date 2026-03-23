import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/shared/widgets/primary_button.dart';

class BaselineAssessmentScreen extends ConsumerStatefulWidget {
  final String enterpriseId;
  const BaselineAssessmentScreen({super.key, required this.enterpriseId});

  @override
  ConsumerState<BaselineAssessmentScreen> createState() => _BaselineAssessmentScreenState();
}

class _BaselineAssessmentScreenState extends ConsumerState<BaselineAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  double _progress = 0.0;

  // Form states (simplified for UI demonstration)
  final Map<String, dynamic> _responses = {};

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
        _progress = (_currentStep / 3);
      });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _progress = (_currentStep / 3);
      });
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Baseline Assessment'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStepHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSection1(), // Business Profile
                _buildSection2(), // Baseline Metrics
                _buildSection3(), // Diagnosis Questions
                _buildSection4(), // Evidence Capture
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ABC Hardware', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Owner: Ayele Tesfaye', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Text('${(_progress * 100).toInt()}% complete', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSection1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Section 1: Business Profile', Icons.business_center),
          const SizedBox(height: AppSpacing.md),
          _buildInfoTile('Enterprise Name', 'ABC Hardware'),
          _buildInfoTile('Owner Name', 'Ayele Tesfaye'),
          _buildInfoTile('Location', 'Bole, Addis Ababa'),
          _buildInfoTile('Contact', '+251 911 234 567'),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('COMPLETED ✓', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Section 2: Baseline Metrics', Icons.analytics),
          const SizedBox(height: AppSpacing.md),
          _buildInputField('Number of Employees', 'e.g. 3'),
          _buildInputField('Monthly Revenue (ETB)', 'e.g. 25,000'),
          const SizedBox(height: AppSpacing.md),
          const Text('Record-Keeping System', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildRadioButton('Yes'),
          _buildRadioButton('No'),
          _buildInputField('If yes, describe', 'e.g. Sales logbook'),
        ],
      ),
    );
  }

  Widget _buildSection3() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildSectionHeader('Section 3: Diagnosis Questions', Icons.list_alt),
        const SizedBox(height: AppSpacing.md),
        _buildCategoryCard('FINANCE', '0/6 questions', Colors.blue),
        _buildCategoryCard('MARKETING', '0/5 questions', Colors.orange),
        _buildCategoryCard('OPERATIONS', '0/6 questions', Colors.green),
        _buildCategoryCard('MANAGEMENT', '0/4 questions', Colors.purple),
        const SizedBox(height: AppSpacing.lg),
        const Text('Sample Questions (Finance):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: AppSpacing.md),
        _buildQuestionCard(1, 'Does the business keep daily sales records?'),
        _buildQuestionCard(2, 'Are business and personal finances separated?'),
      ],
    );
  }

  Widget _buildSection4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Section 4: Evidence Capture', Icons.camera_alt),
          const SizedBox(height: AppSpacing.md),
          _buildUploadTile('Storefront Photo', Icons.store),
          _buildUploadTile('Business License', Icons.description),
          _buildUploadTile('Sales Record Sample', Icons.receipt_long),
          _buildUploadTile('Expense Record', Icons.payments),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(String label) {
    return RadioListTile(
      title: Text(label),
      value: label,
      groupValue: null,
      onChanged: (v) {},
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCategoryCard(String name, String status, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        tileColor: color.withOpacity(0.05),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(status),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, elevation: 0),
          child: const Text('START'),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, String question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$index. $question', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildChoiceChip('Yes'),
            _buildChoiceChip('No'),
            _buildChoiceChip('Sometimes'),
            _buildChoiceChip("I don't know"),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChoiceChip(String label) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: false,
      onSelected: (v) {},
    );
  }

  Widget _buildUploadTile(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('UPLOAD'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('BACK'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              onPressed: _currentStep == 3 ? () {} : _nextStep,
              label: _currentStep == 3 ? 'SUBMIT FOR QC' : 'NEXT STEP',
            ),
          ),
        ],
      ),
    );
  }
}
