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
    final value = box.get('themeMode');
    return value?.toString();
  }

  static Future<void> saveTextSize(String size) async {
    final box = Hive.box(prefsBox);
    await box.put('textSize', size);
  }

  static String? getTextSize() {
    final box = Hive.box(prefsBox);
    final value = box.get('textSize');
    return value?.toString();
  }

  static Future<void> saveHighContrast(bool value) async {
    final box = Hive.box(prefsBox);
    await box.put('highContrast', value);
  }

  static bool? getHighContrast() {
    final box = Hive.box(prefsBox);
    final value = box.get('highContrast');
    if (value is bool) return value;
    if (value?.toString() == 'true') return true;
    if (value?.toString() == 'false') return false;
    return null;
  }

  static Future<void> saveImageQuality(String quality) async {
    final box = Hive.box(prefsBox);
    await box.put('imageQuality', quality);
  }

  static String? getImageQuality() {
    final box = Hive.box(prefsBox);
    final value = box.get('imageQuality');
    return value?.toString();
  }

  static Future<void> saveSyncWifiOnly(bool wifiOnly) async {
    final box = Hive.box(prefsBox);
    await box.put('syncWifiOnly', wifiOnly);
  }

  static bool? getSyncWifiOnly() {
    final box = Hive.box(prefsBox);
    final value = box.get('syncWifiOnly');
    if (value is bool) return value;
    if (value?.toString() == 'true') return true;
    if (value?.toString() == 'false') return false;
    return null;
  }
}
