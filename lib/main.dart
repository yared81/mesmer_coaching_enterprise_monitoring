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
import 'core/services/security_service.dart';
import 'features/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.linux || 
             defaultTargetPlatform == TargetPlatform.windows || 
             defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
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

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  DateTime? _pausedTime;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    Future.microtask(() async {
      await ref.read(authProvider.notifier).checkAuthStatus();
      
      // Only trigger biometric on startup if explicitly enabled in settings
      final isBiometricEnabled = ref.read(systemSettingsProvider).biometricEnabled;
      if (isBiometricEnabled) {
        _isAuthenticating = true;
        final authenticated = await SecurityService.authenticate();
        _isAuthenticating = false;
        
        if (!authenticated && mounted) {
          ref.read(authProvider.notifier).logout();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null && !_isAuthenticating) {
        final settings = ref.read(systemSettingsProvider);
        
        // Check timeout
        if (settings.autoLockTimeout > 0) {
          final difference = DateTime.now().difference(_pausedTime!);
          if (difference.inMinutes >= settings.autoLockTimeout) {
            // Only trigger biometric lock if biometric is explicitly enabled
            if (settings.biometricEnabled) {
              _isAuthenticating = true;
              final authenticated = await SecurityService.authenticate();
              _isAuthenticating = false;

              if (!authenticated && mounted) {
                ref.read(authProvider.notifier).logout();
              }
            }
            // If biometric not enabled, timeout just means we keep the session
            // (user is still logged in — they just need to re-open the app)
          }
        }
      }
      _pausedTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);
    final systemSettings = ref.watch(systemSettingsProvider);

    return MaterialApp.router(
      title: 'MESMER Digital Coaching',
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
