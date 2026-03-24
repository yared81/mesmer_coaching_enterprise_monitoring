import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/hive_storage.dart';

class SystemSettings {
  final String textSize; // 'small', 'medium', 'large', 'xlarge'
  final bool highContrast;
  final String imageQuality; // 'low', 'medium', 'original'
  final bool syncWifiOnly;

  SystemSettings({
    required this.textSize,
    required this.highContrast,
    required this.imageQuality,
    required this.syncWifiOnly,
  });

  SystemSettings copyWith({
    String? textSize,
    bool? highContrast,
    String? imageQuality,
    bool? syncWifiOnly,
  }) {
    return SystemSettings(
      textSize: textSize ?? this.textSize,
      highContrast: highContrast ?? this.highContrast,
      imageQuality: imageQuality ?? this.imageQuality,
      syncWifiOnly: syncWifiOnly ?? this.syncWifiOnly,
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
  SystemSettingsNotifier() : super(SystemSettings(
    textSize: 'medium', 
    highContrast: false,
    imageQuality: 'medium',
    syncWifiOnly: true,
  )) {
    _loadSettings();
  }

  void _loadSettings() {
    final savedSize = HiveStorage.getTextSize() ?? 'medium';
    final savedContrast = HiveStorage.getHighContrast() ?? false;
    final savedImageQual = HiveStorage.getImageQuality() ?? 'medium';
    final savedWifi = HiveStorage.getSyncWifiOnly() ?? true;
    
    state = SystemSettings(
      textSize: savedSize, 
      highContrast: savedContrast,
      imageQuality: savedImageQual,
      syncWifiOnly: savedWifi,
    );
  }

  Future<void> setTextSize(String size) async {
    state = state.copyWith(textSize: size);
    await HiveStorage.saveTextSize(size);
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    await HiveStorage.saveHighContrast(value);
  }

  Future<void> setImageQuality(String quality) async {
    state = state.copyWith(imageQuality: quality);
    await HiveStorage.saveImageQuality(quality);
  }

  Future<void> setSyncWifiOnly(bool wifiOnly) async {
    state = state.copyWith(syncWifiOnly: wifiOnly);
    await HiveStorage.saveSyncWifiOnly(wifiOnly);
  }
}

final systemSettingsProvider = StateNotifierProvider<SystemSettingsNotifier, SystemSettings>((ref) {
  return SystemSettingsNotifier();
});
