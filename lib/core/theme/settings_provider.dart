import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/hive_storage.dart';

class SystemSettings {
  final String textSize; // 'small', 'medium', 'large', 'xlarge'
  final bool highContrast;
  final String imageQuality; // 'low', 'medium', 'original'
  final bool syncWifiOnly;
  final bool biometricEnabled;
  final int autoLockTimeout; // 0, 5, 15, 30 (0 = disabled)

  SystemSettings({
    required this.textSize,
    required this.highContrast,
    required this.imageQuality,
    required this.syncWifiOnly,
    required this.biometricEnabled,
    required this.autoLockTimeout,
  });

  SystemSettings copyWith({
    String? textSize,
    bool? highContrast,
    String? imageQuality,
    bool? syncWifiOnly,
    bool? biometricEnabled,
    int? autoLockTimeout,
  }) {
    return SystemSettings(
      textSize: textSize ?? this.textSize,
      highContrast: highContrast ?? this.highContrast,
      imageQuality: imageQuality ?? this.imageQuality,
      syncWifiOnly: syncWifiOnly ?? this.syncWifiOnly,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
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
    biometricEnabled: false,
    autoLockTimeout: 15, // default 15 minutes
  )) {
    _loadSettings();
  }

  void _loadSettings() {
    final savedSize = HiveStorage.getTextSize() ?? 'medium';
    final savedContrast = HiveStorage.getHighContrast() ?? false;
    final savedImageQual = HiveStorage.getImageQuality() ?? 'medium';
    final savedWifi = HiveStorage.getSyncWifiOnly() ?? true;
    final savedBiometric = HiveStorage.getBiometricEnabled() ?? false;
    final savedLock = HiveStorage.getAutoLockTimeout() ?? 15;
    
    state = SystemSettings(
      textSize: savedSize, 
      highContrast: savedContrast,
      imageQuality: savedImageQual,
      syncWifiOnly: savedWifi,
      biometricEnabled: savedBiometric,
      autoLockTimeout: savedLock,
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

  Future<void> setBiometricEnabled(bool enabled) async {
    state = state.copyWith(biometricEnabled: enabled);
    await HiveStorage.saveBiometricEnabled(enabled);
  }

  Future<void> setAutoLockTimeout(int minutes) async {
    state = state.copyWith(autoLockTimeout: minutes);
    await HiveStorage.saveAutoLockTimeout(minutes);
  }
}

final systemSettingsProvider = StateNotifierProvider<SystemSettingsNotifier, SystemSettings>((ref) {
  return SystemSettingsNotifier();
});
