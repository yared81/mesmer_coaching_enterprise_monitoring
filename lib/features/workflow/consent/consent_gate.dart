import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/features/workflow/consent/consent_provider.dart';
import 'consent_capture_screen.dart';

class ConsentGate extends ConsumerWidget {
  final String enterpriseId;
  final Widget child;

  const ConsentGate({
    super.key,
    required this.enterpriseId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentAsync = ref.watch(enterpriseConsentProvider(enterpriseId));

    return consentAsync.when(
      data: (consent) {
        if (consent != null && consent.isConsented) {
          return child;
        } else {
          return ConsentCaptureScreen(enterpriseId: enterpriseId);
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error checking consent: $err'),
              ElevatedButton(
                onPressed: () => ref.refresh(enterpriseConsentProvider(enterpriseId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
