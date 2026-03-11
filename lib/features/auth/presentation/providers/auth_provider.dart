// TODO: Auth state provider using Riverpod
// States: AuthState { loading | authenticated(user) | unauthenticated | error }
// - Watch this provider in GoRouter for redirect logic
// - Expose login(), logout(), getCurrentUser() methods

import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Define AuthState (sealed class or simple enum + data)
// TODO: class AuthNotifier extends AsyncNotifier<AuthState>
// TODO: final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
