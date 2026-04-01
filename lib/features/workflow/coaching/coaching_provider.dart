import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:mesmer_digital_coaching/core/db/local_database.dart';
import 'coaching_remote_datasource.dart';
import 'coaching_repository_impl.dart';
import 'coaching_repository.dart';
import 'coaching_session_entity.dart';
import 'phone_followup_entity.dart';

final coachingRemoteDataSourceProvider = Provider<CoachingRemoteDataSource>((ref) {
  return CoachingRemoteDataSource(ref.watch(dioProvider));
});

final coachingRepositoryProvider = Provider<CoachingRepository>((ref) {
  return CoachingRepositoryImpl(
    remoteDataSource: ref.watch(coachingRemoteDataSourceProvider),
    localDatabase: ref.watch(localDatabaseProvider),
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
      (failure) => throw Exception(failure.message),
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

// --- Phone Follow-up Providers ---

final phoneFollowupListProvider = StateNotifierProvider<PhoneFollowupListNotifier, AsyncValue<List<PhoneFollowupEntity>>>((ref) {
  return PhoneFollowupListNotifier(ref.watch(coachingRepositoryProvider));
});

class PhoneFollowupListNotifier extends StateNotifier<AsyncValue<List<PhoneFollowupEntity>>> {
  PhoneFollowupListNotifier(this._repository) : super(const AsyncValue.loading()) {
    getLogs();
  }

  final CoachingRepository _repository;

  Future<void> getLogs() async {
    state = const AsyncValue.loading();
    final result = await _repository.getCoachPhoneFollowups();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (logs) => state = AsyncValue.data(logs),
    );
  }

  Future<void> createLog(PhoneFollowupEntity log) async {
    final result = await _repository.createPhoneFollowup(log);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) => getLogs(), // Refresh list on success
    );
  }
}

final enterprisePhoneFollowupsProvider = FutureProvider.family<List<PhoneFollowupEntity>, String>((ref, id) async {
  final repository = ref.watch(coachingRepositoryProvider);
  final result = await repository.getEnterprisePhoneFollowups(id);
  return result.fold(
    (failure) => throw failure.message,
    (logs) => logs,
  );
});

