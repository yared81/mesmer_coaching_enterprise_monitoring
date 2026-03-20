import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import 'graduation_repository.dart';

final graduationRepositoryProvider = Provider<GraduationRepository>((ref) {
  return GraduationRepositoryImpl(ref.watch(dioProvider));
});

final graduationProvider = StateNotifierProvider<GraduationNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return GraduationNotifier(ref.watch(graduationRepositoryProvider));
});

class GraduationNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  GraduationNotifier(this._repository) : super(const AsyncValue.data(null));
  final GraduationRepository _repository;

  Future<void> request(String enterpriseId) async {
    state = const AsyncValue.loading();
    final result = await _repository.requestGraduation(enterpriseId);
    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (data) => state = AsyncValue.data(data),
    );
  }
}
