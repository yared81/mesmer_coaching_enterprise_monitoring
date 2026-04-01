import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Wait for the animation to play out (2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    final authStatus = ref.read(authProvider).status;
    if (authStatus == AuthStatus.authenticated) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF311B92), Color(0xFF1A237E), Colors.black],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PNG Logo with Fallback
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/images/logo.png',
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.eco_rounded,
                      size: 100,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                )
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(delay: 200.ms),
                
                const SizedBox(height: 40),
                
                // Branding
                const Text(
                  'MESMER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 8),
                
                Text(
                  'Digital Coaching Platform'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms),
                
                const SizedBox(height: 60),
                
                // Subtitle / Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Empowering Ethiopian Enterprises through Digital Coaching',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 1100.ms),
              ],
            ),
            
            // Bottom Loading Indicator
            Positioned(
              bottom: 60,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.3)),
                ),
              )
              .animate()
              .fadeIn(delay: 1500.ms),
            ),
          ],
        ),
      ),
    );
  }
}

