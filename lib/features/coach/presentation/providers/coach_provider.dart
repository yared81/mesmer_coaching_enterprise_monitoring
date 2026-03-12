import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/coach_remote_datasource.dart';
import '../../data/repositories/coach_repository_impl.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/usecases/coach_usecases.dart';

// --- Data Layer Providers ---
final coachRemoteDataSourceProvider = Provider<CoachRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CoachRemoteDataSourceImpl(dio: dio);
});

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  final remoteDataSource = ref.watch(coachRemoteDataSourceProvider);
  return CoachRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Domain Layer Providers ---
final getCoachesUseCaseProvider = Provider<GetCoachesUseCase>((ref) {
  final repository = ref.watch(coachRepositoryProvider);
  return GetCoachesUseCase(repository);
});

final registerCoachUseCaseProvider = Provider<RegisterCoachUseCase>((ref) {
  final repository = ref.watch(coachRepositoryProvider);
  return RegisterCoachUseCase(repository);
});

// --- State Management ---
// Provides the list of coaches
final coachListProvider = FutureProvider<List<CoachEntity>>((ref) async {
  final getCoaches = ref.watch(getCoachesUseCaseProvider);
  final result = await getCoaches();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (coaches) => coaches,
  );
});

// Provides state for the registration form (loading/success/error)
class CoachRegistrationNotifier extends StateNotifier<AsyncValue<void>> {
  final RegisterCoachUseCase _registerCoach;

  CoachRegistrationNotifier(this._registerCoach) : super(const AsyncValue.data(null));

  Future<bool> register(String name, String email, String phone) async {
    state = const AsyncValue.loading();
    final result = await _registerCoach(name, email, phone);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

final coachRegistrationProvider = StateNotifierProvider<CoachRegistrationNotifier, AsyncValue<void>>((ref) {
  final registerCoach = ref.watch(registerCoachUseCaseProvider);
  return CoachRegistrationNotifier(registerCoach);
});
