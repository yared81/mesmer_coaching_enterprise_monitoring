import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import 'equipment_entity.dart';
import 'equipment_repository.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/db/local_cache_repository.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepositoryImpl(
    ref.watch(dioProvider),
    ref.watch(localCacheRepositoryProvider),
  );
});

final enterpriseEquipmentProvider = StateNotifierProvider.family<EquipmentNotifier, AsyncValue<List<EquipmentEntity>>, String>((ref, enterpriseId) {
  return EquipmentNotifier(ref.watch(equipmentRepositoryProvider), enterpriseId);
});

class EquipmentNotifier extends StateNotifier<AsyncValue<List<EquipmentEntity>>> {
  final EquipmentRepository _repository;
  final String _enterpriseId;

  EquipmentNotifier(this._repository, this._enterpriseId) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    final result = await _repository.getEnterpriseAssets(_enterpriseId);
    result.fold(
      (f) => state = AsyncValue.error(f.message, StackTrace.current),
      (list) => state = AsyncValue.data(list),
    );
  }

  Future<void> addAsset(EquipmentEntity asset) async {
    final result = await _repository.addAsset(asset);
    result.fold(
      (f) => throw Exception(f.message),
      (_) => fetch(),
    );
  }

  Future<void> updateStatus(String id, EquipmentStatus status, String? notes) async {
    final result = await _repository.updateStatus(id, status, notes);
    result.fold(
      (f) => throw Exception(f.message),
      (_) => fetch(),
    );
  }
}
