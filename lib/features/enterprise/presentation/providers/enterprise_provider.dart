import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/enterprise_remote_datasource.dart';
import '../../data/repositories/enterprise_repository_impl.dart';
import '../../domain/repositories/enterprise_repository.dart';
import '../../domain/usecases/get_enterprises_usecase.dart';
import '../../domain/usecases/register_enterprise_usecase.dart';
import '../../domain/entities/enterprise_entity.dart';

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

// 4. State Management (Notifier)
final enterpriseListProvider = StateNotifierProvider<EnterpriseListNotifier, AsyncValue<List<EnterpriseEntity>>>((ref) {
  return EnterpriseListNotifier(ref.watch(getEnterprisesUseCaseProvider));
});

class EnterpriseListNotifier extends StateNotifier<AsyncValue<List<EnterpriseEntity>>> {
  EnterpriseListNotifier(this._getEnterprises) : super(const AsyncValue.loading()) {
    getEnterprises();
  }

  final GetEnterprisesUseCase _getEnterprises;

  Future<void> getEnterprises({String? search, Sector? sector}) async {
    state = const AsyncValue.loading();
    final result = await _getEnterprises(search: search, sector: sector);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (enterprises) => state = AsyncValue.data(enterprises),
    );
  }
}
