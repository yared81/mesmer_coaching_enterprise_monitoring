import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:mesmer_digital_coaching/features/auth/user_model.dart';
import 'package:mesmer_digital_coaching/features/admin/institution_model.dart';
import 'package:mesmer_digital_coaching/features/admin/user_management_repository.dart';

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserManagementRepositoryImpl(dio);
});

// ─── Filter State (avoids FutureProvider.family Map equality bug) ─────────────

/// Holds the current filter values for the user list.
/// Updating this invalidates [usersListProvider] automatically.
final userFilterProvider = StateProvider<({String? role, String? institution, String? search})>(
  (ref) => (role: null, institution: null, search: null),
);

// ─── Data Providers (simple, non-family — watch filter state) ─────────────────

/// Fetches users based on current filter state.
/// Non-family provider — no Map equality issues.
final usersListProvider = FutureProvider<List<UserModel>>((ref) async {
  final repository = ref.watch(userManagementRepositoryProvider);
  final filters = ref.watch(userFilterProvider);
  final result = await repository.getUsers(
    role: filters.role,
    institutionId: filters.institution,
    search: filters.search,
  );
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

/// Fetches institutions.
/// Key format: "root" or "parentId=<id>"
/// Using String (value equality) instead of Map to prevent infinite loops.
final institutionsListProvider = FutureProvider.family<List<InstitutionModel>, String>((ref, key) async {
  final repository = ref.watch(userManagementRepositoryProvider);
  
  String? parentId;
  bool? isRoot;
  
  if (key == 'root') {
    isRoot = true;
  } else if (key.startsWith('parentId=')) {
    parentId = key.substring(9);
  }
  
  // If key is 'all' or empty, both stay null and repository fetches all.
  
  final result = await repository.getInstitutions(
    parentId: parentId,
    isRoot: isRoot,
  );
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

// ─── Action Notifier ──────────────────────────────────────────────────────────

class UserManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final UserManagementRepository _repository;
  final Ref _ref;

  UserManagementNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> createInstitution(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    final result = await _repository.createInstitution(data);
    result.fold(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) {
        state = const AsyncValue.data(null);
        _ref.invalidate(institutionsListProvider);
      },
    );
  }

  Future<void> updateInstitution(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateInstitution(id, data);
    result.fold(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) {
        state = const AsyncValue.data(null);
        _ref.invalidate(institutionsListProvider);
      },
    );
  }

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
