import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/settings_provider.dart';
import 'features/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.linux || 
             defaultTargetPlatform == TargetPlatform.windows || 
             defaultTargetPlatform == TargetPlatform.macOS) {
    databaseFactory = databaseFactoryFfi;
  }

  await HiveStorage.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check initial auth status on app start
    Future.microtask(() async {
      await ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);
    final systemSettings = ref.watch(systemSettingsProvider);

    return MaterialApp.router(
      title: 'GrowthTrack Coaching',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: systemSettings.highContrast ? AppTheme.highContrastLight : AppTheme.lightTheme,
      darkTheme: systemSettings.highContrast ? AppTheme.highContrastDark : AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(systemSettings.textScaleFactor),
            highContrast: systemSettings.highContrast,
            boldText: systemSettings.highContrast,
          ),
          child: child!,
        );
      },
    );
  }
}
