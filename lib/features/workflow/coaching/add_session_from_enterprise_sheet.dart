import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/widgets/custom_toaster.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_session_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/diagnosis_provider.dart';
import 'package:geolocator/geolocator.dart';

/// A lighter session creation sheet that pre-selects the enterprise.
/// Designed to be shown as a modal bottom sheet from the EnterpriseDetailScreen.
class AddSessionFromEnterpriseSheet extends ConsumerStatefulWidget {
  final String enterpriseId;
  const AddSessionFromEnterpriseSheet({super.key, required this.enterpriseId});

  @override
  ConsumerState<AddSessionFromEnterpriseSheet> createState() =>
      _AddSessionFromEnterpriseSheetState();
}

class _AddSessionFromEnterpriseSheetState
    extends ConsumerState<AddSessionFromEnterpriseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedTemplateId;
  DateTime _selectedDate = DateTime.now();
  int _sessionNumber = 1;
  FollowupType _followupType = FollowupType.physical;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    double? lat;
    double? lng;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
          lat = position.latitude;
          lng = position.longitude;
        }
      }
    } catch (e) {
      // Ignore location errors, just proceed without GPS metadata
      print("Location error: $e");
    }

    final session = CoachingSessionEntity(
      id: '',
      title: _titleController.text.trim(),
      enterpriseId: widget.enterpriseId,
      templateId: _selectedTemplateId,
      coachId: user.id,
      scheduledDate: _selectedDate,
      status: SessionStatus.scheduled,
      sessionNumber: _sessionNumber,
      followupType: _followupType,
      notes: '',
      problemsIdentified: '',
      recommendations: '',
      latitude: lat,
      longitude: lng,
    );

    try {
      await ref.read(coachingSessionsProvider.notifier).createSession(session);
      // Invalidate the enterprise's session cache so timeline refreshes
      ref.invalidate(enterpriseSessionsProvider(widget.enterpriseId));
      ref.invalidate(coachingSessionsProvider);
      if (mounted) {
        CustomToaster.show(context: context, message: 'Session created successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        CustomToaster.show(context: context, message: 'Failed to create session: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'New Coaching Session',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Recording a new session for this enterprise.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Title field
              TextFormField(
                controller: _titleController,
                autofocus: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a session title' : null,
                decoration: InputDecoration(
                  labelText: 'Session Title',
                  hintText: 'e.g. Initial Assessment, Follow-up Review...',
                  prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF3D5AFE)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3D5AFE), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Assessment Profile Dropdown
              const Text(
                'Assessment Profile',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              ref.watch(allTemplatesProvider).when(
                data: (list) => DropdownButtonFormField<String>(
                  value: _selectedTemplateId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Select Assessment Tool',
                    prefixIcon: const Icon(Icons.assessment_outlined, color: Color(0xFF3D5AFE)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: list.map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text(
                      t.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedTemplateId = val),
                  validator: (val) => val == null ? 'Please select a profile' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading profiles: $err', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 16),

              const Text('Session Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      'Physical', 
                      Icons.location_on_outlined, 
                      _followupType == FollowupType.physical,
                      () => setState(() => _followupType = FollowupType.physical),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeCard(
                      'Phone', 
                      Icons.phone_outlined, 
                      _followupType == FollowupType.phone,
                      () => setState(() => _followupType = FollowupType.phone),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Session Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF3D5AFE), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5AFE),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Create Session',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D5AFE).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF3D5AFE) : Colors.grey[300]!, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF3D5AFE) : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF3D5AFE) : Colors.grey[700],
            )),
          ],
        ),
      ),
    );
  }
}
