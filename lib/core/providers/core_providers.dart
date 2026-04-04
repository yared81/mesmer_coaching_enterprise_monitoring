import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mesmer_digital_coaching/core/network/dio_client.dart';
import 'package:mesmer_digital_coaching/core/network/offline_provider.dart';
import 'package:mesmer_digital_coaching/core/storage/secure_storage.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(ref.watch(flutterSecureStorageProvider));
});

/// Callback registered by main.dart to force logout when refresh token expires.
/// This breaks the circular dependency between dioProvider and authProvider.
void Function()? globalForceLogoutCallback;

final dioProvider = Provider<Dio>((ref) {
  return DioClient.createDio(
    ref.watch(secureStorageProvider),
    ref.watch(offlineModeProvider.notifier),
    onForceLogout: () => globalForceLogoutCallback?.call(),
  );
});
