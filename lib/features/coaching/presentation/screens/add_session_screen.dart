import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../enterprise/presentation/providers/enterprise_provider.dart';
import '../providers/coaching_provider.dart';
import '../../domain/entities/coaching_session_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddSessionScreen extends ConsumerStatefulWidget {
  const AddSessionScreen({super.key});

  @override
  ConsumerState<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends ConsumerState<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEnterpriseId;
  DateTime _selectedDate = DateTime.now();
  SessionStatus _status = SessionStatus.completed;
  final _notesController = TextEditingController();
  final _problemsController = TextEditingController();
  final _recommendationsController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _problemsController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedEnterpriseId == null) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final session = CoachingSessionEntity(
      id: '', // Backend generates UUID
      enterpriseId: _selectedEnterpriseId!,
      coachId: user.id,
      scheduledDate: _selectedDate,
      status: _status,
      notes: _notesController.text,
      problemsIdentified: _problemsController.text,
      recommendations: _recommendationsController.text,
    );

    await ref.read(coachingSessionsProvider.notifier).createSession(session);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final enterprisesAsync = ref.watch(filteredEnterprisesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Session', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enterprise', style: TextStyle(fontWeight: FontWeight.bold)),
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
              
              const Text('Session Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              
              _buildTextField('Problems Identified', _problemsController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Recommendations', _recommendationsController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('General Notes', _notesController, maxLines: 4),
              
              const SizedBox(height: 40),
              
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}
