import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access GrowthTrack Coaching',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows PIN fallback
        ),
      );
    } catch (e) {
      // Hardware exceptions
      return false;
    }
  }
}
