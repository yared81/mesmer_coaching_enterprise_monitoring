import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart' hide Column;
import 'package:mesmer_digital_coaching/features/workflow/training/training_entity.dart';
import 'package:mesmer_digital_coaching/features/workflow/training/training_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/training/training_repository.dart';
import 'package:mesmer_digital_coaching/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_digital_coaching/core/widgets/qr_scanner_screen.dart';

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
  final Map<String, String> _insights = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with existing attendance if available
    for (var a in widget.training.attendances) {
      _attendance[a.enterpriseId] = a.attended;
      if (a.feedbackScore != null) _scores[a.enterpriseId] = a.feedbackScore!;
      if (a.trainerInsight != null) _insights[a.enterpriseId] = a.trainerInsight!;
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    
    final List<Map<String, dynamic>> data = _attendance.keys.map((id) => {
      'enterprise_id': id,
      'attended': _attendance[id] ?? false,
      'feedback_score': _scores[id] ?? 3,
      'trainer_insight': _insights[id],
    }).toList();

    final result = await ref.read(trainingRepositoryProvider).updateAttendance(widget.training.id, data);
    
    if (mounted) {
      result.fold(
        (failure) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sync: ${failure.message}'), backgroundColor: Colors.red),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance synced successfully'), backgroundColor: Colors.green),
          );
          ref.read(trainingsProvider.notifier).fetch(); // Refresh list to update count
          Navigator.pop(context);
        },
      );
    }
  }

  Future<void> _sendReminders() async {
    final result = await ref.read(trainingRepositoryProvider).sendReminders(widget.training.id);
    
    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send: ${failure.message}'), backgroundColor: Colors.red),
          );
        },
        (count) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sent reminders to $count enterprises'), backgroundColor: Colors.blue),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final enterprisesAsync = ref.watch(enterpriseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance: ${widget.training.title}'),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: enterprises.length,
                itemBuilder: (context, index) {
                  final e = enterprises[index];
                  final attended = _attendance[e.id] ?? false;
                  final score = _scores[e.id] ?? 3;
                  final insight = _insights[e.id] ?? '';

                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(e.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: attended 
                          ? Row(
                              children: [
                                const Text('Score: ', style: TextStyle(fontSize: 12)),
                                ...List.generate(5, (i) => Icon(
                                  Icons.star, 
                                  size: 16, 
                                  color: (i < score) ? Colors.amber : Theme.of(context).disabledColor,
                                )),
                                const Spacer(),
                                DropdownButton<int>(
                                  value: score,
                                  items: [1, 2, 3, 4, 5].map((i) => DropdownMenuItem(value: i, child: Text('$i'))).toList(),
                                  onChanged: (val) => setState(() => _scores[e.id] = val ?? 3),
                                ),
                              ],
                            )
                          : Text('Not Attended', style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 12)),
                        value: attended,
                        onChanged: (val) => setState(() {
                          _attendance[e.id] = val ?? false;
                          if (val == true && !_scores.containsKey(e.id)) _scores[e.id] = 3;
                        }),
                        secondary: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.blueAccent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QRScannerScreen(
                                  onScan: (code) {
                                    if (code.contains(widget.training.id)) {
                                      setState(() {
                                        _attendance[e.id] = true;
                                        if (!_scores.containsKey(e.id)) _scores[e.id] = 3;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Verified: ${e.businessName} is present')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Invalid QR for this session'), backgroundColor: Colors.red),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        activeColor: const Color(0xFF3D5AFE),
                      ),
                      if (attended)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 8),
                          child: TextField(
                            onChanged: (val) => _insights[e.id] = val,
                            controller: TextEditingController(text: insight)..selection = TextSelection.collapsed(offset: insight.length),
                            decoration: const InputDecoration(
                              labelText: 'Trainer Insight / Feedback',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ),
                      const Divider(),
                    ],
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
