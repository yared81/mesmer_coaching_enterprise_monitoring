import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'coaching_provider.dart';
import 'coaching_session_entity.dart';
import 'add_session_screen.dart';
import 'session_detail_screen.dart';

class CoachSessionListScreen extends ConsumerWidget {
  const CoachSessionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(coachingSessionsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Coaching Sessions', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        backgroundColor: const Color(0xFF3D5AFE),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionCard(session: session);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text('Unable to load sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              const Text('Please check your connection and try again.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(coachingSessionsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sessions/new'),
        label: const Text('New Session'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF3D5AFE),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No sessions recorded yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final CoachingSessionEntity session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == SessionStatus.completed;
    final isPendingSync = session.id.startsWith('offline_');

    // Theme colors based on status
    final Color themeColor;
    final Color lightBg;
    final String statusLabel;
    final IconData statusIcon;

    if (isPendingSync) {
      themeColor = Colors.grey[700]!;
      lightBg = Colors.grey[200]!;
      statusLabel = 'Pending Sync ...';
      statusIcon = Icons.hourglass_empty_rounded;
    } else {
      themeColor = isCompleted ? const Color(0xFF1E3A8A) : const Color(0xFF16A34A);
      lightBg = isCompleted ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4);
      statusLabel = isCompleted ? 'Completed' : 'Draft';
      statusIcon = isCompleted ? Icons.check_circle_rounded : Icons.edit_note_rounded;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: themeColor.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/sessions/detail', extra: session);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: themeColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: themeColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 13, color: themeColor),
                        const SizedBox(width: 4),
                        Text(statusLabel, 
                          style: TextStyle(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        if (!isPendingSync && isCompleted) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.cloud_done_rounded, size: 11, color: Color(0xFF1E3A8A)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (session.notes != null && session.notes!.isNotEmpty)
                Text(
                  session.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              if (session.notes != null && session.notes!.isNotEmpty)
                const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          session.enterpriseName ?? 'Enterprise ID: ${session.enterpriseId.substring(0, 8)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd, yyyy').format(session.scheduledDate),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
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

