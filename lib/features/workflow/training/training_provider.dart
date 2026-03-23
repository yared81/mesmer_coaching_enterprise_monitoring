import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'training_entity.dart';
import 'training_repository.dart';

final trainingsProvider = StateNotifierProvider<TrainingsNotifier, AsyncValue<List<TrainingEntity>>>((ref) {
  return TrainingsNotifier(ref.watch(trainingRepositoryProvider));
});

class TrainingsNotifier extends StateNotifier<AsyncValue<List<TrainingEntity>>> {
  final TrainingRepository _repository;
  TrainingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    final result = await _repository.getSessions();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (sessions) => state = AsyncValue.data(sessions),
    );
  }

  Future<void> create(TrainingEntity session) async {
    final result = await _repository.createSession(session);
    result.fold(
      (failure) => null, // Handle error in UI
      (newSession) => fetch(), // Refresh list
    );
  }

  Future<void> delete(String id) async {
    final result = await _repository.deleteSession(id);
    result.fold(
      (failure) => null,
      (_) => fetch(),
    );
  }
}

final trainingDetailProvider = FutureProvider.family<TrainingEntity, String>((ref, id) async {
  final repo = ref.watch(trainingRepositoryProvider);
  final result = await repo.getSessionById(id);
  return result.fold(
    (failure) => throw failure.message,
    (session) => session,
  );
});

final myAttendanceProvider = FutureProvider<List<TrainingAttendanceEntity>>((ref) async {
  final repo = ref.watch(trainingRepositoryProvider);
  final result = await repo.getMyAttendance();
  return result.fold(
    (failure) => throw failure.message,
    (list) => list,
  );
});

final trainerStatsProvider = FutureProvider<TrainerStats>((ref) async {
  final repo = ref.watch(trainingRepositoryProvider);
  final result = await repo.getTrainerStats();
  return result.fold(
    (failure) => throw failure.message,
    (stats) => stats,
  );
});
