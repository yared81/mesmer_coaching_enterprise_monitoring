import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'report_remote_datasource.dart';
import 'report_repository.dart';
import 'report_repository_impl.dart';

// 1. Datasource
final reportRemoteDatasourceProvider = Provider<ReportRemoteDatasource>((ref) {
  return ReportRemoteDatasource(ref.watch(dioProvider));
});

// 2. Repository
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(reportRemoteDatasourceProvider));
});

// 3. Download state notifiers

/// Downloads an individual enterprise PDF — returns the raw bytes on success.
final enterprisePdfDownloadProvider =
    StateNotifierProvider.family<DownloadNotifier, AsyncValue<List<int>?>, String>(
  (ref, enterpriseId) => DownloadNotifier(
    () => ref.read(reportRepositoryProvider).downloadEnterprisePdf(enterpriseId),
  ),
);

/// Downloads the system-wide master CSV — returns the raw bytes on success.
final masterCsvDownloadProvider =
    StateNotifierProvider<DownloadNotifier, AsyncValue<List<int>?>>(
  (ref) => DownloadNotifier(
    () => ref.read(reportRepositoryProvider).downloadMasterCsv(),
  ),
);

/// Downloads the weekly coach summary PDF — returns the raw bytes on success.
final weeklyReportDownloadProvider =
    StateNotifierProvider<DownloadNotifier, AsyncValue<List<int>?>>(
  (ref) => DownloadNotifier(
    () => ref.read(reportRepositoryProvider).downloadWeeklyReport(),
  ),
);

/// Generic download notifier that holds loading / data / error state for a
/// binary file download and exposes a [download()] trigger.
class DownloadNotifier extends StateNotifier<AsyncValue<List<int>?>> {
  DownloadNotifier(this._fetch) : super(const AsyncValue.data(null));

  final Future<List<int>> Function() _fetch;

  Future<void> download() async {
    state = const AsyncValue.loading();
    try {
      final bytes = await _fetch();
      state = AsyncValue.data(bytes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}
