import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier to track the network/server reachability state.
/// This allows the repositories to fallback to SQLite when the Node.js backend is unreachable.
final offlineModeProvider = StateNotifierProvider<OfflineModeNotifier, bool>((ref) {
  return OfflineModeNotifier();
});

class OfflineModeNotifier extends StateNotifier<bool> {
  OfflineModeNotifier() : super(false);

  /// Set the app to offline/standalone mode.
  void setOffline(bool value) {
    if (state != value) {
      state = value;
      print('🌐 App switched to ${value ? "OFFLINE/STANDALONE" : "ONLINE"} mode.');
    }
  }

  /// Toggle offline mode.
  void toggleOffline() => setOffline(!state);
}
