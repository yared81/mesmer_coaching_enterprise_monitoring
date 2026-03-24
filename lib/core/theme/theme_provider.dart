import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/hive_storage.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = HiveStorage.getThemeMode();
    if (savedTheme != null) {
      if (savedTheme == 'light') state = ThemeMode.light;
      else if (savedTheme == 'dark') state = ThemeMode.dark;
      else state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final String modeString = mode == ThemeMode.light ? 'light' : 
                              mode == ThemeMode.dark ? 'dark' : 'system';
    await HiveStorage.saveThemeMode(modeString);
  }
}
