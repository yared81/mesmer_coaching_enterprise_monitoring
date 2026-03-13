import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/coaching_remote_datasource.dart';
import '../../data/repositories/coaching_repository_impl.dart';
import '../../domain/repositories/coaching_repository.dart';
import '../../domain/entities/coaching_session_entity.dart';

final coachingRemoteDataSourceProvider = Provider<CoachingRemoteDataSource>((ref) {
  return CoachingRemoteDataSource(ref.watch(dioProvider));
});

final coachingRepositoryProvider = Provider<CoachingRepository>((ref) {
  return CoachingRepositoryImpl(
    remoteDataSource: ref.watch(coachingRemoteDataSourceProvider),
  );
});

final coachingSessionsProvider = StateNotifierProvider<CoachingSessionsNotifier, AsyncValue<List<CoachingSessionEntity>>>((ref) {
  return CoachingSessionsNotifier(ref.watch(coachingRepositoryProvider));
});

class CoachingSessionsNotifier extends StateNotifier<AsyncValue<List<CoachingSessionEntity>>> {
  CoachingSessionsNotifier(this._repository) : super(const AsyncValue.loading()) {
    getSessions();
  }

  final CoachingRepository _repository;

  Future<void> getSessions() async {
    state = const AsyncValue.loading();
    final result = await _repository.getMySessions();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (sessions) => state = AsyncValue.data(sessions),
    );
  }

  Future<void> createSession(CoachingSessionEntity session) async {
    final result = await _repository.createSession(session);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) => getSessions(), // Refresh list on success
    );
  }

  Future<void> updateSession(CoachingSessionEntity session) async {
    final result = await _repository.updateSession(session);
    result.fold(
      (failure) => null, // Handle error UI if needed
      (_) => getSessions(), // Refresh list on success
    );
  }
}

final enterpriseSessionsProvider = FutureProvider.family<List<CoachingSessionEntity>, String>((ref, id) async {
  final repository = ref.watch(coachingRepositoryProvider);
  final result = await repository.getEnterpriseSessions(id);
  return result.fold(
    (failure) => throw failure.message,
    (sessions) => sessions,
  );
});

final coachingSessionProvider = FutureProvider.family<CoachingSessionEntity?, String>((ref, sessionId) async {
  // Simple search in the list for now, or fetch from repo if needed
  // Since we usually have the list loaded, we can try matching. 
  // But for direct links (deep links), we should fetch.
  final repository = ref.watch(coachingRepositoryProvider);
  // Assuming the repository has a getSessionById or similar. 
  // If not, we'll use getMySessions and find.
  final result = await repository.getMySessions();
  return result.fold(
    (failure) => null,
    (sessions) => sessions.firstWhere((s) => s.id == sessionId),
  );
});
