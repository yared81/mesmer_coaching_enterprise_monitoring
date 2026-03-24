import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/hive_storage.dart';

class SystemSettings {
  final String textSize; // 'small', 'medium', 'large', 'xlarge'
  final bool highContrast;

  SystemSettings({
    required this.textSize,
    required this.highContrast,
  });

  SystemSettings copyWith({
    String? textSize,
    bool? highContrast,
  }) {
    return SystemSettings(
      textSize: textSize ?? this.textSize,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  double get textScaleFactor {
    switch (textSize) {
      case 'small': return 0.85;
      case 'medium': return 1.0;
      case 'large': return 1.15;
      case 'xlarge': return 1.30;
      default: return 1.0;
    }
  }
}

class SystemSettingsNotifier extends StateNotifier<SystemSettings> {
  SystemSettingsNotifier() : super(SystemSettings(textSize: 'medium', highContrast: false)) {
    _loadSettings();
  }

  void _loadSettings() {
    final savedSize = HiveStorage.getTextSize() ?? 'medium';
    final savedContrast = HiveStorage.getHighContrast() ?? false;
    state = SystemSettings(textSize: savedSize, highContrast: savedContrast);
  }

  Future<void> setTextSize(String size) async {
    state = state.copyWith(textSize: size);
    await HiveStorage.saveTextSize(size);
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    await HiveStorage.saveHighContrast(value);
  }
}

final systemSettingsProvider = StateNotifierProvider<SystemSettingsNotifier, SystemSettings>((ref) {
  return SystemSettingsNotifier();
});
