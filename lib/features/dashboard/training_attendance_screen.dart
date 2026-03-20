import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/training/training_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/training/training_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';

class TrainingAttendanceScreen extends ConsumerStatefulWidget {
  final TrainingEntity training;
  const TrainingAttendanceScreen({super.key, required this.training});

  @override
  ConsumerState<TrainingAttendanceScreen> createState() => _TrainingAttendanceScreenState();
}

class _TrainingAttendanceScreenState extends ConsumerState<TrainingAttendanceScreen> {
  // Map of enterpriseId -> (Attended, Score)
  final Map<String, bool> _attendance = {};
  final Map<String, int> _scores = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with existing attendance if available
    for (var a in widget.training.attendances) {
      _attendance[a.enterpriseId] = a.attended;
      if (a.feedbackScore != null) _scores[a.enterpriseId] = a.feedbackScore!;
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    
    final List<Map<String, dynamic>> data = _attendance.keys.map((id) => {
      'enterprise_id': id,
      'attended': _attendance[id] ?? false,
      'feedback_score': _scores[id],
    }).toList();

    try {
      await ref.read(trainingsProvider.notifier).submitAttendance(widget.training.id, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance synced successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sendReminders() async {
    try {
      final count = await ref.read(trainingsProvider.notifier).sendReminders(widget.training.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sent reminders to $count enterprises'), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enterprisesAsync = ref.watch(enterpriseListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Attendance: ${widget.training.title}'),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sms_outlined),
            tooltip: 'Send Reminders',
            onPressed: () => _sendReminders(),
          ),
        ],
      ),
      body: enterprisesAsync.when(
        data: (enterprises) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: enterprises.length,
                itemBuilder: (context, index) {
                  final e = enterprises[index];
                  final attended = _attendance[e.id] ?? false;
                  final score = _scores[e.id] ?? 3;

                  return CheckboxListTile(
                    title: Text(e.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: attended 
                      ? Row(
                          children: [
                            const Text('Feedback: ', style: TextStyle(fontSize: 12)),
                            ...List.generate(5, (i) => Icon(
                              Icons.star, 
                              size: 16, 
                              color: (i < score) ? Colors.amber : Colors.grey[300],
                            )),
                            const Spacer(),
                            DropdownButton<int>(
                              value: score,
                              items: [1, 2, 3, 4, 5].map((i) => DropdownMenuItem(value: i, child: Text('$i'))).toList(),
                              onChanged: (val) => setState(() => _scores[e.id] = val ?? 3),
                            ),
                          ],
                        )
                      : const Text('Not Attended', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: attended,
                    onChanged: (val) => setState(() {
                      _attendance[e.id] = val ?? false;
                      if (val == true && !_scores.containsKey(e.id)) _scores[e.id] = 3;
                    }),
                    secondary: const Icon(Icons.business_center_outlined, color: Colors.blueGrey),
                    activeColor: const Color(0xFF3D5AFE),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5AFE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save & Sync Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
