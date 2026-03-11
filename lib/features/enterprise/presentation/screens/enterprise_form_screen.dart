import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/enterprise_provider.dart';
import '../../domain/entities/enterprise_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

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
  Sector _selectedSector = Sector.other;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _employeeCountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 1) {
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
      'email': _emailController.text.isEmpty ? null : _emailController.text,
    };

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
        title: const Text('Register Enterprise'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
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
          _buildStepCircle(1, 'Contact Info'),
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
            hint: 'e.g. Blue Nile Manufacturing',
            prefixIcon: const Icon(Icons.business),
            validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
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
          AppTextField(
            controller: _employeeCountController,
            label: 'Employee Count',
            hint: 'Number of employees',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.people),
          ),
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
            hint: 'Full name',
            prefixIcon: const Icon(Icons.person),
            validator: (v) => v == null || v.isEmpty ? 'Owner name is required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+251...',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone),
            validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'City, Region',
            prefixIcon: const Icon(Icons.location_on),
            validator: (v) => v == null || v.isEmpty ? 'Location is required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _emailController,
            label: 'Email (Optional)',
            hint: 'email@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
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
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: BorderRadius.circular(12),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            child: PrimaryButton(
              onPressed: _isLoading ? () {} : _nextStep,
              text: _currentStep == 1 ? 'Complete Registration' : 'Next Step',
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
