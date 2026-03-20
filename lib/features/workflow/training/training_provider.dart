import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import 'training_entity.dart';
import 'training_repository.dart';

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  return TrainingRepositoryImpl(
    ref.watch(dioProvider),
    ref.watch(localCacheRepositoryProvider),
  );
});

final trainingsProvider = StateNotifierProvider<TrainingsNotifier, AsyncValue<List<TrainingEntity>>>((ref) {
  return TrainingsNotifier(ref.watch(trainingRepositoryProvider));
});

class TrainingsNotifier extends StateNotifier<AsyncValue<List<TrainingEntity>>> {
  TrainingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetch();
  }
  final TrainingRepository _repository;

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    final result = await _repository.getMyTrainings();
    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (list) => state = AsyncValue.data(list),
    );
  }

  Future<void> create(TrainingEntity training) async {
    final result = await _repository.createTraining(training);
    result.fold(
      (f) => throw Exception(f.message),
      (_) => fetch(),
    );
  }

  Future<void> submitAttendance(String id, List<Map<String, dynamic>> data) async {
    final result = await _repository.updateAttendance(id, data);
    result.fold(
      (f) => throw Exception(f.message),
      (_) => fetch(),
    );
  }

  Future<int> sendReminders(String id) async {
    final result = await _repository.sendReminders(id);
    return result.fold(
      (f) => throw Exception(f.message),
      (count) => count,
    );
  }
}
