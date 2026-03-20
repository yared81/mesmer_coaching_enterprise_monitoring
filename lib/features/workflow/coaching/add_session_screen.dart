import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'coaching_provider.dart';
import 'coaching_session_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/diagnosis_provider.dart';

class AddSessionScreen extends ConsumerStatefulWidget {
  const AddSessionScreen({super.key});

  @override
  ConsumerState<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends ConsumerState<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedEnterpriseId;
  String? _selectedTemplateId;
  DateTime _selectedDate = DateTime.now();
  int _sessionNumber = 1;
  FollowupType _followupType = FollowupType.physical;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedEnterpriseId == null) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final session = CoachingSessionEntity(
      id: '', // Backend generates UUID
      title: _titleController.text.trim(),
      enterpriseId: _selectedEnterpriseId!,
      templateId: _selectedTemplateId,
      coachId: user.id,
      scheduledDate: _selectedDate,
      status: SessionStatus.scheduled, 
      sessionNumber: _sessionNumber,
      followupType: _followupType,
      notes: '',
      problemsIdentified: '',
      recommendations: '',
    );

    try {
      await ref.read(coachingSessionsProvider.notifier).createSession(session);
      
      // Force the enterprise's session list to refresh its cache
      ref.invalidate(enterpriseSessionsProvider(_selectedEnterpriseId!));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session created successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create session: $e'), 
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enterprisesAsync = ref.watch(filteredEnterprisesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Session', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Session Title', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Initial Assessment, Follow-up Review...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Enterprise / Institution', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              enterprisesAsync.when(
                data: (list) => DropdownButtonFormField<String>(
                  value: _selectedEnterpriseId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  hint: const Text('Select Enterprise'),
                  items: list.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.businessName),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedEnterpriseId = val),
                  validator: (val) => val == null ? 'Please select an enterprise' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading enterprises: $err'),
              ),
              const SizedBox(height: 24),

              const Text('Assessment Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ref.watch(allTemplatesProvider).when(
                data: (list) => DropdownButtonFormField<String>(
                  value: _selectedTemplateId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  hint: const Text('Select Assessment Tool'),
                  items: list.map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text(t.title),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedTemplateId = val),
                  validator: (val) => val == null ? 'Please select a profile' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading profiles: $err'),
              ),
              const SizedBox(height: 24),

              const Text('Session Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      'Physical Visit', 
                      Icons.location_on_outlined, 
                      _followupType == FollowupType.physical,
                      () => setState(() => _followupType = FollowupType.physical),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeCard(
                      'Phone Call', 
                      Icons.phone_outlined, 
                      _followupType == FollowupType.phone,
                      () => setState(() => _followupType = FollowupType.phone),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Session Number (Graduation Track)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _sessionNumber,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: List.generate(8, (i) => i + 1).map((n) => DropdownMenuItem(
                  value: n,
                  child: Text('Session #$n'),
                )).toList(),
                onChanged: (val) => setState(() => _sessionNumber = val ?? 1),
              ),
              const SizedBox(height: 24),
              
              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate), 
                           style: const TextStyle(fontSize: 16)),
                      const Icon(Icons.calendar_month, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5AFE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Create Session', 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D5AFE).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF3D5AFE) : Colors.grey[300]!, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF3D5AFE) : Colors.grey),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF3D5AFE) : Colors.grey[700],
            )),
          ],
        ),
      ),
    );
  }
}

