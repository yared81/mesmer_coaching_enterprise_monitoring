import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/training_attendance_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/training/training_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/training/training_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/widgets/sync_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingsAsync = ref.watch(trainingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Trainer Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        actions: [
          const SyncIndicator(),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showScheduleModal(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: trainingsAsync.when(
        data: (trainings) => trainings.isEmpty
            ? _buildEmptyState(context, ref)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: trainings.length,
                itemBuilder: (context, index) {
                  final training = trainings[index];
                  return _TrainingCard(training: training)
                      .animate(delay: (100 * index).ms)
                      .fadeIn(duration: 500.ms)
                      .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No training sessions scheduled', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showScheduleModal(context, ref),
            child: const Text('Schedule First Workshop'),
          ),
        ],
      ),
    );
  }

  void _showScheduleModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _ScheduleTrainingBottomSheet(),
    );
  }
}

class _ScheduleTrainingBottomSheet extends ConsumerStatefulWidget {
  const _ScheduleTrainingBottomSheet();
  @override
  ConsumerState<_ScheduleTrainingBottomSheet> createState() => _ScheduleTrainingBottomSheetState();
}

class _ScheduleTrainingBottomSheetState extends ConsumerState<_ScheduleTrainingBottomSheet> {
  final _titleController = TextEditingController();
  final _locController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Schedule New Workshop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Training Title')),
            TextField(controller: _locController, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Date: ${DateFormat('MMM dd, yyyy').format(_date)}'),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime(2030));
                if (d != null) setState(() => _date = d);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final training = TrainingEntity(
                  id: '',
                  title: _titleController.text,
                  location: _locController.text,
                  date: _date,
                  trainerId: ref.read(authProvider).user!.id,
                );
                await ref.read(trainingsProvider.notifier).create(training);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Schedule'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final TrainingEntity training;
  const _TrainingCard({required this.training});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(training.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy • hh:mm a').format(training.date), style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(training.location ?? 'TBD', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(training.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            training.status.name.toUpperCase(),
            style: TextStyle(color: _getStatusColor(training.status), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TrainingAttendanceScreen(training: training)));
        },
      ),
    );
  }

  Color _getStatusColor(TrainingStatus status) {
    switch (status) {
      case TrainingStatus.completed: return Colors.green;
      case TrainingStatus.cancelled: return Colors.red;
      case TrainingStatus.upcoming: return Colors.blue;
    }
  }
}
