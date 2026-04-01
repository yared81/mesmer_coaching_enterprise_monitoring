import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_digital_coaching/features/workflow/enterprise/enterprise_provider.dart';
import 'coaching_provider.dart';
import 'coaching_session_entity.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/diagnosis/diagnosis_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mesmer_digital_coaching/core/theme/app_colors.dart';

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
  // Session number is automatically determined — not manually set by user
  int _nextSessionNumber = 1;
  bool _isLoadingSessionNumber = false;
  FollowupType _followupType = FollowupType.physical;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// When the user selects an enterprise, this fetches the existing sessions
  /// to determine the correct next session number automatically.
  Future<void> _onEnterpriseSelected(String? enterpriseId) async {
    if (enterpriseId == null) return;
    setState(() {
      _selectedEnterpriseId = enterpriseId;
      _isLoadingSessionNumber = true;
    });

    try {
      final repository = ref.read(coachingRepositoryProvider);
      final result = await repository.getEnterpriseSessions(enterpriseId);
      result.fold(
        (failure) {
          // On error, default to session 1
          setState(() {
            _nextSessionNumber = 1;
            _isLoadingSessionNumber = false;
          });
        },
        (sessions) {
          // Find the highest existing session number and add 1
          final completedNumbers = sessions
              .where((s) => s.sessionNumber != null)
              .map((s) => s.sessionNumber!)
              .toList();

          final next = completedNumbers.isEmpty
              ? 1
              : (completedNumbers.reduce((a, b) => a > b ? a : b) + 1);

          setState(() {
            _nextSessionNumber = next.clamp(1, 8);
            _isLoadingSessionNumber = false;
          });
        },
      );
    } catch (_) {
      setState(() {
        _nextSessionNumber = 1;
        _isLoadingSessionNumber = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedEnterpriseId == null) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    // GPS: fetch with a 5-second timeout to prevent UI hanging
    double? lat;
    double? lng;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 5),
          ).timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw Exception('GPS timeout'),
          );
          lat = position.latitude;
          lng = position.longitude;
        }
      }
    } catch (e) {
      // Location is optional — session can still be created without GPS
      debugPrint('Location skipped: $e');
    }

    final session = CoachingSessionEntity(
      id: '',
      title: _titleController.text.trim(),
      enterpriseId: _selectedEnterpriseId!,
      templateId: _selectedTemplateId,
      coachId: user.id,
      scheduledDate: _selectedDate,
      status: SessionStatus.scheduled,
      sessionNumber: _nextSessionNumber,
      followupType: _followupType,
      notes: '',
      problemsIdentified: '',
      recommendations: '',
      latitude: lat,
      longitude: lng,
    );

    try {
      await ref.read(coachingSessionsProvider.notifier).createSession(session);
      ref.invalidate(enterpriseSessionsProvider(_selectedEnterpriseId!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Session', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  fillColor: Theme.of(context).cardColor,
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
                    fillColor: Theme.of(context).cardColor,
                  ),
                  hint: const Text('Select Enterprise'),
                  items: list
                      .map((e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.businessName),
                          ))
                      .toList(),
                  onChanged: _onEnterpriseSelected,
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
                    fillColor: Theme.of(context).cardColor,
                  ),
                  hint: const Text('Select Assessment Tool'),
                  items: list
                      .map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.title),
                          ))
                      .toList(),
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

              // ── Auto-Determined Session Number ──────────────────────────────
              const Text('Session Number (Auto-Determined)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoadingSessionNumber
                    ? const Row(
                        children: [
                          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Checking existing sessions...', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.playlist_add_check_rounded, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            _selectedEnterpriseId == null
                                ? 'Select an enterprise first'
                                : 'Session #$_nextSessionNumber of 8',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
              ),
              if (_nextSessionNumber > 8)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠️ This enterprise has already completed all 8 coaching sessions.',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
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
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_month, color: Theme.of(context).hintColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _nextSessionNumber > 8) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor: Theme.of(context).disabledColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Create Session',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
