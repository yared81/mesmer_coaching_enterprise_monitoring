import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static const String diagnosisDraftsBox = 'diagnosis_drafts';
  static const String prefsBox = 'system_prefs';
  static const String cachedEnterprisesBox = 'cached_enterprises';
  static const String cachedDashboardsBox = 'cached_dashboards';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(diagnosisDraftsBox),
      Hive.openBox(prefsBox),
      Hive.openBox(cachedEnterprisesBox),
      Hive.openBox(cachedDashboardsBox),
    ]);
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

  static Future<void> clearAllCache() async {
    await Hive.box(diagnosisDraftsBox).clear();
    await Hive.box(cachedEnterprisesBox).clear();
    await Hive.box(cachedDashboardsBox).clear();
  }

  // --- Offline Data Caching ---
  static Future<void> cacheEnterprises(String roleKey, String jsonList) async {
    final box = Hive.box(cachedEnterprisesBox);
    await box.put(roleKey, jsonList);
  }

  static String? getCachedEnterprises(String roleKey) {
    final box = Hive.box(cachedEnterprisesBox);
    return box.get(roleKey)?.toString();
  }

  static Future<void> cacheDashboardStats(String roleKey, String jsonStats) async {
    final box = Hive.box(cachedDashboardsBox);
    await box.put(roleKey, jsonStats);
  }

  static String? getCachedDashboardStats(String roleKey) {
    final box = Hive.box(cachedDashboardsBox);
    return box.get(roleKey)?.toString();
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

  // --- Security Preferences ---
  static Future<void> saveBiometricEnabled(bool enabled) async {
    final box = Hive.box(prefsBox);
    await box.put('biometricEnabled', enabled);
  }

  static bool? getBiometricEnabled() {
    final box = Hive.box(prefsBox);
    final value = box.get('biometricEnabled');
    if (value is bool) return value;
    if (value?.toString() == 'true') return true;
    if (value?.toString() == 'false') return false;
    return null;
  }

  static Future<void> saveAutoLockTimeout(int minutes) async {
    final box = Hive.box(prefsBox);
    await box.put('autoLockTimeout', minutes);
  }

  static int? getAutoLockTimeout() {
    final box = Hive.box(prefsBox);
    final value = box.get('autoLockTimeout');
    if (value is int) return value;
    if (value != null) return int.tryParse(value.toString());
    return null;
  }
}
