import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'calendar_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_session_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<CoachingSessionEntity> _getSessionsForDay(DateTime day, List<CoachingSessionEntity> sessions) {
    return sessions.where((session) {
      if (session.scheduledDate == null) return false;
      return isSameDay(session.scheduledDate!, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(coachSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaching Calendar'),
      ),
      body: sessionsAsync.when(
        data: (sessions) => Column(
          children: [
            _buildCalendar(sessions),
            const SizedBox(height: 8),
            Expanded(
              child: _buildSessionList(sessions),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/sessions/new'),
        icon: const Icon(Icons.add_task),
        label: const Text('Schedule'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildCalendar(List<CoachingSessionEntity> sessions) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        eventLoader: (day) => _getSessionsForDay(day, sessions),
        calendarStyle: const CalendarStyle(
          markerDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFFE3F2FD),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSessionList(List<CoachingSessionEntity> sessions) {
    final daySessions = _getSessionsForDay(_selectedDay!, sessions);

    if (daySessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No sessions for this day', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: daySessions.length,
      itemBuilder: (ctx, i) {
        final s = daySessions[i];
        final isScheduled = s.status == 'scheduled';
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: isScheduled ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              child: Icon(
                isScheduled ? Icons.calendar_today_rounded : Icons.check_circle_rounded,
                color: isScheduled ? Colors.orange : Colors.green,
                size: 20,
              ),
            ),
            title: Text(s.title ?? 'Coaching Session', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Time: ${s.scheduledDate != null ? DateFormat('HH:mm').format(s.scheduledDate!) : "TBD"}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to session detail
            },
          ),
        );
      },
    );
  }
}
