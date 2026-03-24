import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static const String diagnosisDraftsBox = 'diagnosis_drafts';
  static const String prefsBox = 'system_prefs';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(diagnosisDraftsBox);
    await Hive.openBox(prefsBox);
  }

  static Future<void> saveDraft(String sessionId, Map<String, String> responses) async {
    final box = Hive.box(diagnosisDraftsBox);
    await box.put(sessionId, responses);
  }

  static Map<String, String>? getDraft(String sessionId) {
    final box = Hive.box(diagnosisDraftsBox);
    final data = box.get(sessionId);
    if (data != null) {
      return Map<String, String>.from(data);
    }
    return null;
  }

  static Future<void> clearDraft(String sessionId) async {
    final box = Hive.box(diagnosisDraftsBox);
    await box.delete(sessionId);
  }

  // --- Theme Preferences ---
  static Future<void> saveThemeMode(String mode) async {
    final box = Hive.box(prefsBox);
    await box.put('themeMode', mode);
  }

  static String? getThemeMode() {
    final box = Hive.box(prefsBox);
    return box.get('themeMode');
  }

  static Future<void> saveTextSize(String size) async {
    final box = Hive.box(prefsBox);
    await box.put('textSize', size);
  }

  static String? getTextSize() {
    final box = Hive.box(prefsBox);
    return box.get('textSize');
  }

  static Future<void> saveHighContrast(bool value) async {
    final box = Hive.box(prefsBox);
    await box.put('highContrast', value);
  }

  static bool? getHighContrast() {
    final box = Hive.box(prefsBox);
    return box.get('highContrast');
  }
}
