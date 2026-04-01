import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_digital_coaching/features/workflow/training/training_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/training/training_entity.dart';
import 'package:mesmer_digital_coaching/core/widgets/sync_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingsAsync = ref.watch(trainingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
        data: (trainings) => RefreshIndicator(
          onRefresh: () async {
            ref.read(trainingsProvider.notifier).fetch();
            ref.refresh(trainerStatsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsSummary(context, ref),
              const SizedBox(height: 24),
              const Text('Your Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (trainings.isEmpty)
                _buildEmptyState(context, ref)
              else
                ...trainings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final training = entry.value;
                  return _TrainingCard(training: training)
                      .animate(delay: (100 * index).ms)
                      .fadeIn(duration: 500.ms)
                      .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic);
                }),
            ],
          ),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _ScheduleTrainingBottomSheet(),
    );
  }

  Widget _buildStatsSummary(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(trainerStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (err, _) => const SizedBox.shrink(),
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard('Sessions', stats.totalSessions.toString(), Icons.event_available, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('Attendees', stats.totalAttendees.toString(), Icons.people, Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Avg Score', '${stats.averageScore} / 5', Icons.star, Colors.amber),
              const SizedBox(width: 12),
              _buildStatCard('Completion', '${stats.completionRate}%', Icons.check_circle, Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
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
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  TrainingModule _selectedModule = TrainingModule.bookkeeping;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('Schedule New Workshop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Training Title', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<TrainingModule>(
              value: _selectedModule,
              decoration: const InputDecoration(labelText: 'Module', border: OutlineInputBorder()),
              items: TrainingModule.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name.replaceAll('_', ' ').toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedModule = v!),
            ),
            const SizedBox(height: 16),
            TextField(controller: _locController, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(_date)),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime(2030));
                      if (d != null) setState(() => _date = d);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: _startTime);
                      if (t != null) setState(() => _startTime = t);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: _endTime);
                      if (t != null) setState(() => _endTime = t);
                    },
                  ),
                ),
              ],
            ),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Trainer Notes', border: OutlineInputBorder()), maxLines: 2),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111827), foregroundColor: Colors.white),
                onPressed: () async {
                  final String startStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00';
                  final String endStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00';
                  
                  final training = TrainingEntity(
                    id: '',
                    title: _titleController.text,
                    module: _selectedModule,
                    location: _locController.text,
                    date: _date,
                    startTime: startStr,
                    endTime: endStr,
                    notes: _notesController.text,
                    trainerId: '', // Set by backend from token
                  );
                  await ref.read(trainingsProvider.notifier).create(training);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Create Session'),
              ),
            ),
            const SizedBox(height: 32),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.trainingDetail.replaceAll(':id', training.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(training.module.name.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: Colors.blue[800], fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  _StatusBadge(status: training.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                training.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(DateFormat('EEE, MMM dd, yyyy').format(training.date), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${training.startTime.substring(0, 5)} - ${training.endTime.substring(0, 5)}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(training.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('${training.attendeeCount} / ${training.capacity} Registered', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.trainingAttendance.replaceAll(':id', training.id), extra: training),
                    child: const Text('Attendance'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TrainingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    switch (status) {
      case TrainingStatus.completed: color = Colors.green; break;
      case TrainingStatus.cancelled: color = Colors.red; break;
      case TrainingStatus.scheduled: color = Colors.orange; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
