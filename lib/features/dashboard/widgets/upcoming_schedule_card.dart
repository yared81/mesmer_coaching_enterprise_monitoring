import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';
import 'package:mesmer_digital_coaching/features/workflow/coaching/coaching_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/training/training_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/coaching/coaching_session_entity.dart';
import 'package:mesmer_digital_coaching/features/workflow/training/training_entity.dart';

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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Upcoming Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            
            // Combine and sort events
            sessionsAsync.when(
              data: (sessions) => trainingsAsync.when(
                data: (trainings) {
                  final upcomingEvents = _getSortedEvents(sessions, trainings);
                  if (upcomingEvents.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No upcoming events scheduled.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: upcomingEvents.take(3).map((e) => _buildEventItem(e)).toList(),
                  );
                },
                loading: () => const Center(child: LinearProgressIndicator()),
                error: (e, _) => Text('Error loading trainings: $e'),
              ),
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, _) => Text('Error loading sessions: $e'),
            ),
            
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.calendar),
                child: const Text('View Full Calendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ScheduledEvent> _getSortedEvents(List<CoachingSessionEntity> sessions, List<TrainingEntity> trainings) {
    final now = DateTime.now();
    final events = <_ScheduledEvent>[];

    // Add sessions
    for (final s in sessions) {
      if (s.scheduledDate.isAfter(now)) {
        events.add(_ScheduledEvent(
          title: s.title.isNotEmpty ? s.title : 'Coaching Session',
          date: s.scheduledDate,
          type: _EventType.session,
          location: 'In-person',
        ));
      }
    }

    // Add trainings
    for (final t in trainings) {
      if (t.date.isAfter(now)) {
        events.add(_ScheduledEvent(
          title: t.title,
          date: t.date,
          type: _EventType.training,
          location: 'In-person',
        ));
      }
    }

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  Widget _buildEventItem(_ScheduledEvent event) {
    final isSession = event.type == _EventType.session;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isSession ? Colors.blue : Colors.purple).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSession ? Icons.person_outline : Icons.groups_outlined,
              color: isSession ? Colors.blue : Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${DateFormat('MMM dd, hh:mm a').format(event.date)} • ${event.location}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _EventType { session, training }

class _ScheduledEvent {
  final String title;
  final DateTime date;
  final _EventType type;
  final String location;

  _ScheduledEvent({required this.title, required this.date, required this.type, required this.location});
}
