import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'consent_repository.dart';
import 'consent_repository_impl.dart';
import 'consent_record_entity.dart';

final consentRepositoryProvider = Provider<ConsentRepository>((ref) {
  return ConsentRepositoryImpl(ref.watch(dioProvider));
});

final enterpriseConsentProvider = FutureProvider.family<ConsentRecordEntity?, String>((ref, enterpriseId) async {
  final repository = ref.watch(consentRepositoryProvider);
  final result = await repository.getConsentByEnterprise(enterpriseId);
  return result.fold(
    (failure) => throw failure.message,
    (consent) => consent,
  );
});

final consentListProvider = FutureProvider<List<ConsentRecordEntity>>((ref) async {
  final repository = ref.watch(consentRepositoryProvider);
  final result = await repository.listConsents();
  return result.fold(
    (failure) => throw failure.message,
    (consents) => consents,
  );
});

class ConsentNotifier extends StateNotifier<AsyncValue<ConsentRecordEntity?>> {
  final ConsentRepository _repository;

  ConsentNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> submitConsent({
    required String enterpriseId,
    required bool isConsented,
    required bool safeguardingAcknowledged,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.createConsent({
      'enterprise_id': enterpriseId,
      'is_consented': isConsented,
      'safeguarding_acknowledged': safeguardingAcknowledged,
      'notes': notes,
      'method': 'checkbox',
    });

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (consent) {
        state = AsyncValue.data(consent);
        return true;
      },
    );
  }
}

final consentSubmitProvider = StateNotifierProvider<ConsentNotifier, AsyncValue<ConsentRecordEntity?>>((ref) {
  return ConsentNotifier(ref.watch(consentRepositoryProvider));
});
