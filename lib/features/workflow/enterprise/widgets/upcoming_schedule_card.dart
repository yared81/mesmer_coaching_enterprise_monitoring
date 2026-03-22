import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/training/training_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/training/training_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_session_entity.dart';

class UpcomingScheduleCard extends ConsumerWidget {
  final String enterpriseId;

  const UpcomingScheduleCard({super.key, required this.enterpriseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(enterpriseSessionsProvider(enterpriseId));
    final trainingsAsync = ref.watch(trainingsProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month_outlined, color: Color(0xFF1E3A8A), size: 24),
                SizedBox(width: 12),
                Text(
                  'Upcoming Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            sessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading sessions: $err'),
              data: (sessions) {
                return trainingsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading trainings: $err'),
                  data: (trainings) {
                    final upcoming = _getCombinedSchedule(sessions, trainings);
                    if (upcoming.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No upcoming sessions or trainings.',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: upcoming.map((item) => _buildScheduleTile(item)).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getCombinedSchedule(List<CoachingSessionEntity> sessions, List<TrainingEntity> trainings) {
    final now = DateTime.now();
    
    // Filter out past events
    final upcomingSessions = sessions.where((s) => s.scheduledDate.isAfter(now)).toList();
    final upcomingTrainings = trainings.where((t) => t.date.isAfter(now)).toList();

    // Combine and sort by date
    final combined = [...upcomingSessions, ...upcomingTrainings];
    combined.sort((a, b) {
      final dateA = a is CoachingSessionEntity ? a.scheduledDate : (a as TrainingEntity).date;
      final dateB = b is CoachingSessionEntity ? b.scheduledDate : (b as TrainingEntity).date;
      return dateA.compareTo(dateB);
    });

    return combined.take(3).toList(); // Show top 3
  }

  Widget _buildScheduleTile(dynamic item) {
    final isSession = item is CoachingSessionEntity;
    final title = isSession ? item.title : (item as TrainingEntity).title;
    final date = isSession ? item.scheduledDate : (item as TrainingEntity).date;
    final type = isSession ? 'Coaching Session' : 'Training Event';
    final color = isSession ? Colors.blue : Colors.purple;
    final icon = isSession ? Icons.person_outline : Icons.groups_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(date).toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
                ),
                Text(
                  DateFormat('dd').format(date),
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(icon, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$type • ${DateFormat('jm').format(date)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
