abstract class ReportRepository {
  Future<List<int>> downloadEnterprisePdf(String enterpriseId);
  Future<List<int>> downloadMasterCsv();
  Future<List<int>> downloadWeeklyReport();
}
