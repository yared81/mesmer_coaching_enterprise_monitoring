import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static const String diagnosisDraftsBox = 'diagnosis_drafts';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(diagnosisDraftsBox);
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
}
