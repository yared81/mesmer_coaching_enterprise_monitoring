import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/dio_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/institution_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/user_management_repository.dart';

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserManagementRepositoryImpl(dio);
});

final usersListProvider = FutureProvider.family<List<UserModel>, Map<String, String?>>((ref, filters) async {
  final repository = ref.watch(userManagementRepositoryProvider);
  final result = await repository.getUsers(
    role: filters['role'],
    institutionId: filters['institution_id'],
    search: filters['search'],
  );
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

final institutionsListProvider = FutureProvider<List<InstitutionModel>>((ref) async {
  final repository = ref.watch(userManagementRepositoryProvider);
  final result = await repository.getInstitutions();
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

class UserManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final UserManagementRepository _repository;
  final Ref _ref;

  UserManagementNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> createUser(Map<String, dynamic> userData) async {
    state = const AsyncValue.loading();
    final result = await _repository.createUser(userData);
    result.fold(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) {
        state = const AsyncValue.data(null);
        _ref.invalidate(usersListProvider);
      },
    );
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateUser(userId, userData);
    result.fold(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) {
        state = const AsyncValue.data(null);
        _ref.invalidate(usersListProvider);
      },
    );
  }

  Future<void> toggleStatus(String userId) async {
    state = const AsyncValue.loading();
    final result = await _repository.toggleUserStatus(userId);
    result.fold(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) {
        state = const AsyncValue.data(null);
        _ref.invalidate(usersListProvider);
      },
    );
  }
}

final userManagementActionProvider = StateNotifierProvider<UserManagementNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return UserManagementNotifier(repository, ref);
});
