import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/enterprise_remote_datasource.dart';
import '../../data/repositories/enterprise_repository_impl.dart';
import '../../domain/repositories/enterprise_repository.dart';
import '../../domain/usecases/get_enterprises_usecase.dart';
import '../../domain/usecases/register_enterprise_usecase.dart';
import '../../domain/usecases/update_enterprise_usecase.dart';
import '../../domain/entities/enterprise_entity.dart';
import '../../domain/entities/enterprise_dashboard_stats.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// 1. Datasource Provider
final enterpriseRemoteDataSourceProvider = Provider<EnterpriseRemoteDatasource>((ref) {
  return EnterpriseRemoteDatasource(ref.watch(dioProvider));
});

// 2. Repository Provider
final enterpriseRepositoryProvider = Provider<EnterpriseRepository>((ref) {
  return EnterpriseRepositoryImpl(ref.watch(enterpriseRemoteDataSourceProvider));
});

// 3. UseCase Providers
final getEnterprisesUseCaseProvider = Provider<GetEnterprisesUseCase>((ref) {
  return GetEnterprisesUseCase(ref.watch(enterpriseRepositoryProvider));
});

final registerEnterpriseUseCaseProvider = Provider<RegisterEnterpriseUseCase>((ref) {
  return RegisterEnterpriseUseCase(ref.watch(enterpriseRepositoryProvider));
});

final updateEnterpriseUseCaseProvider = Provider<UpdateEnterpriseUseCase>((ref) {
  return UpdateEnterpriseUseCase(ref.watch(enterpriseRepositoryProvider));
});

// 4. State Management (Notifier)
final enterpriseListProvider = StateNotifierProvider<EnterpriseListNotifier, AsyncValue<List<EnterpriseEntity>>>((ref) {
  return EnterpriseListNotifier(
    ref.watch(getEnterprisesUseCaseProvider),
    ref.watch(updateEnterpriseUseCaseProvider),
  );
});

class EnterpriseListNotifier extends StateNotifier<AsyncValue<List<EnterpriseEntity>>> {
  EnterpriseListNotifier(this._getEnterprises, this._updateEnterprise) : super(const AsyncValue.loading()) {
    getEnterprises();
  }

  final GetEnterprisesUseCase _getEnterprises;
  final UpdateEnterpriseUseCase _updateEnterprise;

  Future<void> getEnterprises({String? search, Sector? sector}) async {
    state = const AsyncValue.loading();
    final result = await _getEnterprises(search: search, sector: sector);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (enterprises) => state = AsyncValue.data(enterprises),
    );
  }

  Future<bool> assignEnterprise(String enterpriseId, String? coachId) async {
    final result = await _updateEnterprise(enterpriseId, {'coach_id': coachId});
    return result.fold(
      (failure) => false,
      (updatedEnterprise) {
        // Optimistically update the list
        if (state is AsyncData) {
          final currentList = state.value!;
          state = AsyncValue.data(currentList.map((e) => e.id == enterpriseId ? updatedEnterprise : e).toList());
        }
        return true;
      },
    );
  }
}

// 5. Filtered Provider for Coach
final coachEnterpriseSectorFilterProvider = StateProvider<Sector?>((ref) => null);

final filteredEnterprisesProvider = Provider<AsyncValue<List<EnterpriseEntity>>>((ref) {
  final enterprisesAsync = ref.watch(enterpriseListProvider);
  final user = ref.watch(authProvider).user;
  final sectorFilter = ref.watch(coachEnterpriseSectorFilterProvider);

  return enterprisesAsync.whenData((list) {
    if (user == null) return [];
    return list.where((e) {
      final matchesCoach = e.coachId == user.id;
      final matchesSector = sectorFilter == null || e.sector == sectorFilter;
      return matchesCoach && matchesSector;
    }).toList();
  });
});

// 6. Enterprise Dashboard Provider
final enterpriseDashboardStatsProvider = FutureProvider<EnterpriseDashboardStats>((ref) async {
  final repo = ref.watch(enterpriseRepositoryProvider);
  final result = await repo.getEnterpriseDashboardStats();
  return result.fold(
    (failure) => throw failure.message,
    (stats) => stats,
  );
});
