import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'enterprise_entity.dart';
import 'enterprise_dashboard_stats.dart';

abstract class EnterpriseRepository {
  Future<Either<Failure, List<EnterpriseEntity>>> getEnterprises({
    String? search,
    String? sector,
    String? status,
    String? coachId,
  });
  
  Future<Either<Failure, EnterpriseEntity>> getEnterpriseById(String id);
  
  Future<Either<Failure, EnterpriseEntity>> registerEnterprise(Map<String, dynamic> data);
  
  Future<Either<Failure, EnterpriseEntity>> updateEnterprise(String id, Map<String, dynamic> data);

  Future<Either<Failure, EnterpriseDashboardStats>> getEnterpriseDashboardStats();

  Future<Either<Failure, List<EnterpriseEntity>>> bulkRegister(List<Map<String, dynamic>> enterprises);
  
  Future<Either<Failure, List<Map<String, dynamic>>>> getEnterpriseTrends(String id);
}
