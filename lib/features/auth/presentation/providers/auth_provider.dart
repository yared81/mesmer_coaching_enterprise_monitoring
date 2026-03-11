import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/entities/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/repositories/auth_repository.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/usecases/login_usecase.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/usecases/logout_usecase.dart';

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

// --- Auth Presentation State ---

enum AuthStatus { authenticated, unauthenticated, initial }

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
    state = const AuthState(status: AuthStatus.initial); // or loading
    final result = await _ref.read(loginUseCaseProvider)(email, password);
    state = result.fold(
      (failure) => AuthState.unauthenticated(error: failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> logout() async {
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
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
