import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() {
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

    return MaterialApp.router(
      title: 'GrowthTrack Coaching',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF3D5AFE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5AFE),
          primary: const Color(0xFF3D5AFE),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white.withOpacity(0.15),
          selectedColor: Colors.white,
          secondarySelectedColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          secondaryLabelStyle: const TextStyle(color: Color(0xFF3D5AFE), fontWeight: FontWeight.bold, fontSize: 12),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
