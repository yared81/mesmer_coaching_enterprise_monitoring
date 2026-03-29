import 'report_remote_datasource.dart';
import 'report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._remote);
  final ReportRemoteDatasource _remote;

  @override
  Future<List<int>> downloadEnterprisePdf(String enterpriseId) =>
      _remote.downloadEnterprisePdf(enterpriseId);

  @override
  Future<List<int>> downloadMasterCsv() => _remote.downloadMasterCsv();

  @override
  Future<List<int>> downloadWeeklyReport() => _remote.downloadWeeklyReport();
}
