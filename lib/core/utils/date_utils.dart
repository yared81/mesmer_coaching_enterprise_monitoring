import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatShort(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  static String formatFull(DateTime date) =>
      DateFormat('MMMM dd, yyyy').format(date);

  static String formatWithTime(DateTime date) =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatShort(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isOverdue(DateTime deadline) =>
      deadline.isBefore(DateTime.now());
}
