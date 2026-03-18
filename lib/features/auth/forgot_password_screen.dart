// TODO: Forgot password screen
// - Email input field
// - Submit button → calls POST /auth/forgot-password
// - Brevo sends reset email (handled by backend)
// - Show success/error feedback

import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement forgot password UI
    return const Scaffold(
      body: Center(child: Text('Forgot Password — TODO')),
    );
  }
}
