class StringUtils {
  static String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String titleCase(String s) =>
      s.split(' ').map(capitalize).join(' ');

  static String truncate(String s, int maxLength) =>
      s.length <= maxLength ? s : '${s.substring(0, maxLength)}…';

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static String snakeToLabel(String snake) =>
      titleCase(snake.replaceAll('_', ' '));
}
