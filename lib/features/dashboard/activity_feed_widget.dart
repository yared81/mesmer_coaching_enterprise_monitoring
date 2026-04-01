import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_stats_entity.dart';

class ActivityFeedWidget extends StatelessWidget {
  final List<ActivityEntity> activities;
  final Function(ActivityEntity)? onActivityTap;

  const ActivityFeedWidget({
    super.key, 
    required this.activities,
    this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        ),
        child: const Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Recent Updates',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              height: 1,
              indent: 70,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onActivityTap != null ? () => onActivityTap!(activity) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getBgColor(activity.type, isDark),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(activity.type),
                            color: _getIconColor(activity.type),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activity.description,
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('MMM d').format(activity.timestamp),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
  const SizedBox(height: 12),
        ],
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'enterprise': return Icons.storefront_rounded;
      case 'session': return Icons.event_note_rounded;
      case 'phone_call': return Icons.phone_in_talk_rounded;
      case 'assessment': return Icons.assessment_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'enterprise': return Colors.blue[700]!;
      case 'session': return const Color(0xFF3D5AFE);
      case 'phone_call': return Colors.green[700]!;
      case 'assessment': return Colors.orange[700]!;
      default: return Colors.grey[700]!;
    }
  }

  Color _getBgColor(String? type, bool isDark) {
    final baseColor = _getIconColor(type);
    if (isDark) {
      return baseColor.withValues(alpha: 0.12);
    }
    switch (type) {
      case 'enterprise': return Colors.blue[50]!;
      case 'session': return const Color(0xFF3D5AFE).withValues(alpha: 0.08);
      case 'phone_call': return Colors.green[50]!;
      case 'assessment': return Colors.orange[50]!;
      default: return Colors.grey[50]!;
    }
  }
}
