import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/errors/failure.dart';
import 'qc_audit_entity.dart';
import 'qc_repository.dart';

final qcRemoteDataSourceProvider = Provider<QcRemoteDataSource>((ref) {
  return QcRemoteDataSource(ref.watch(dioProvider));
});

final qcRepositoryProvider = Provider<QcRepository>((ref) {
  return QcRepositoryImpl(ref.watch(qcRemoteDataSourceProvider));
});

final pendingAuditsProvider = StateNotifierProvider<PendingAuditsNotifier, AsyncValue<List<QcAuditEntity>>>((ref) {
  return PendingAuditsNotifier(ref.watch(qcRepositoryProvider));
});

final qcAuditProvider = FutureProvider.family<QcAuditEntity, String>((ref, id) async {
  final repo = ref.watch(qcRepositoryProvider);
  final result = await repo.getAuditById(id);
  return result.fold(
    (failure) => throw failure.message,
    (audit) => audit,
  );
});

class PendingAuditsNotifier extends StateNotifier<AsyncValue<List<QcAuditEntity>>> {
  PendingAuditsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetch();
  }

  final QcRepository _repository;

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    final result = await _repository.getPendingAudits();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (audits) => state = AsyncValue.data(audits),
    );
  }

  Future<void> review(String id, QcAuditStatus status, String? comments) async {
    final result = await _repository.reviewAudit(id, status, comments);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => fetch(), // Refresh list on success
    );
  }
}
