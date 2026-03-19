import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'enterprise_provider.dart';
import 'enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/shared/widgets/primary_button.dart';
import 'package:mesmer_coaching_enterprise_monitoring/shared/widgets/app_text_field.dart';

class EnterpriseFormScreen extends ConsumerStatefulWidget {
  const EnterpriseFormScreen({super.key});

  @override
  ConsumerState<EnterpriseFormScreen> createState() => _EnterpriseFormScreenState();
}

class _EnterpriseFormScreenState extends ConsumerState<EnterpriseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _employeeCountController = TextEditingController();
  final TextEditingController _businessAgeController = TextEditingController();
  final TextEditingController _revenueController = TextEditingController();
  final TextEditingController _challengesController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  
  Sector _selectedSector = Sector.other;
  OwnerGender _selectedGender = OwnerGender.male;
  PremiseType _selectedPremiseType = PremiseType.rented;
  RecordKeepingSystem _selectedRecordKeeping = RecordKeepingSystem.none;
  bool _hasConsented = false;

  @override
  void dispose() {
    _revenueController.dispose();
    _challengesController.dispose();
    _loanAmountController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _employeeCountController.dispose();
    _businessAgeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'business_name': _nameController.text,
      'owner_name': _ownerController.text,
      'sector': _selectedSector.name,
      'employee_count': int.tryParse(_employeeCountController.text) ?? 0,
      'location': _locationController.text,
      'phone': _phoneController.text,
      'email': _emailController.text.trim(),
      'business_age': int.tryParse(_businessAgeController.text) ?? 0,
      'owner_gender': _selectedGender.name,
      'premise_type': _selectedPremiseType.name,
      'baseline_revenue': double.tryParse(_revenueController.text) ?? 0.0,
      'loan_amount': double.tryParse(_loanAmountController.text) ?? 0.0,
      'challenges': _challengesController.text,
      'record_keeping_system': _selectedRecordKeeping.name,
      'consent_status': _hasConsented,
      'consent_date': _hasConsented ? DateTime.now().toIso8601String() : null,
      'baseline_employees': int.tryParse(_employeeCountController.text) ?? 0,
    };

    if (!_hasConsented) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must capture owner consent to proceed.'), backgroundColor: Colors.red),
      );
      return;
    }

    final result = await ref.read(registerEnterpriseUseCaseProvider)(data);

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (enterprise) {
        ref.read(enterpriseListProvider.notifier).getEnterprises();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enterprise registered successfully!'), backgroundColor: Colors.green),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Register Enterprise', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Row(
        children: [
          _buildStepCircle(0, 'Business Info'),
          Expanded(child: Container(height: 2, color: _currentStep > 0 ? AppColors.primary : Colors.grey[300])),
          _buildStepCircle(1, 'Owner & Layout'),
          Expanded(child: Container(height: 2, color: _currentStep > 1 ? AppColors.primary : Colors.grey[300])),
          _buildStepCircle(2, 'Baseline & Consent'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primary : Colors.grey[300]!),
            boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
          ),
          child: Center(
            child: isActive 
              ? (_currentStep > step ? const Icon(Icons.check, size: 16, color: Colors.white) : Text('${step + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
              : Text('${step + 1}', style: TextStyle(color: Colors.grey[400])),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppColors.textPrimary : Colors.grey[400], fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about the business', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _nameController,
            label: 'Business Name',
            prefixIcon: const Icon(Icons.business),
            validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _businessAgeController,
                  label: 'Established / Working years',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  controller: _employeeCountController,
                  label: 'Employee Count',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.people),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Sector', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Sector>(
                value: _selectedSector,
                isExpanded: true,
                items: Sector.values.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                )).toList(),
                onChanged: (v) => setState(() => _selectedSector = v!),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Premise Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PremiseType>(
                value: _selectedPremiseType,
                isExpanded: true,
                items: PremiseType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.name.replaceAll('_', ' ').split(' ').map((e) => e[0].toUpperCase() + e.substring(1)).join(' ')),
                )).toList(),
                onChanged: (v) => setState(() => _selectedPremiseType = v!),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Baseline score is not required for now (we derive health from submitted assessments)
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Primary Contact Person', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _ownerController,
            label: 'Owner Name',
            prefixIcon: const Icon(Icons.person),
            validator: (v) => v == null || v.isEmpty ? 'Owner name is required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Gender', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: OwnerGender.values.map((g) => Expanded(
              child: RadioListTile<OwnerGender>(
                title: Text(g.name[0].toUpperCase() + g.name.substring(1), style: const TextStyle(fontSize: 12)),
                value: g,
                groupValue: _selectedGender,
                onChanged: (v) => setState(() => _selectedGender = v!),
                contentPadding: EdgeInsets.zero,
              ),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _phoneController,
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone),
            validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _locationController,
            label: 'Location',
            prefixIcon: const Icon(Icons.location_on),
            validator: (v) => v == null || v.isEmpty ? 'Location is required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Email is required';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Baseline & Consent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _revenueController,
            label: 'Baseline Revenue (ETB)',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _loanAmountController,
            label: 'Total Loan Disbursed (if any)',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.account_balance),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Record Keeping System', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RecordKeepingSystem>(
                value: _selectedRecordKeeping,
                isExpanded: true,
                items: RecordKeepingSystem.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.name.replaceAll('_', ' ').split(' ').map((e) => e[0].toUpperCase() + e.substring(1)).join(' ')),
                )).toList(),
                onChanged: (v) => setState(() => _selectedRecordKeeping = v!),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _challengesController,
            label: 'Primary Challenges (Optional)',
            prefixIcon: const Icon(Icons.warning_amber),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: CheckboxListTile(
              title: const Text('Digital Consent Captured', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('I confirm the enterprise owner has consented to participate in the program and share data.', style: TextStyle(fontSize: 12)),
              value: _hasConsented,
              onChanged: (val) => setState(() => _hasConsented = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(0, 56), // Ensure consistent height
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2, // Give more room to the primary action button
            child: PrimaryButton(
              onPressed: _isLoading ? null : _nextStep,
              label: _currentStep == 2 ? 'Complete Registration' : 'Next Step',
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
