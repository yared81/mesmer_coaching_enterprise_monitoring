import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_remote_datasource.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_repository_impl.dart';
import 'package:mesmer_digital_coaching/features/auth/user_entity.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_repository.dart';
import 'package:mesmer_digital_coaching/features/auth/get_current_user_usecase.dart';
import 'package:mesmer_digital_coaching/features/auth/login_usecase.dart';
import 'package:mesmer_digital_coaching/features/auth/logout_usecase.dart';

// --- Auth Data & Domain Providers ---

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final lastUserRoleProvider = FutureProvider<String?>((ref) async {
  return ref.watch(secureStorageProvider).getLastUserRole();
});

// --- Auth Presentation State ---

enum AuthStatus { authenticated, unauthenticated, loading, initial }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.authenticated(UserEntity user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated({String? error}) => AuthState(status: AuthStatus.unauthenticated, errorMessage: error);

  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(AuthState.initial());

  final Ref _ref;

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    final result = await _ref.read(loginUseCaseProvider)(email, password);
    state = await result.fold(
      (failure) async => AuthState.unauthenticated(error: failure.message),
      (user) async {
        await _ref.read(secureStorageProvider).saveLastUserRole(user.role.name);
        return AuthState.authenticated(user);
      },
    );
  }

  Future<void> logout() async {
    final currentUser = state.user;
    if (currentUser != null) {
      await _ref.read(secureStorageProvider).saveLastUserRole(currentUser.role.name);
    }
    await _ref.read(logoutUseCaseProvider)();
    state = AuthState.unauthenticated();
  }

  Future<void> checkAuthStatus() async {
    final token = await _ref.read(secureStorageProvider).getAccessToken();
    if (token == null) {
      state = AuthState.unauthenticated();
      return;
    }

    final result = await _ref.read(getCurrentUserUseCaseProvider)();
    state = result.fold(
      (failure) => AuthState.unauthenticated(),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> updateProfile(String name, String email) async {
    final result = await _ref.read(authRepositoryProvider).updateProfile(name, email);
    result.fold(
      (failure) {
        // Optionally handle failure state or notify UI
      },
      (user) {
        state = AuthState.authenticated(user);
      },
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
