import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/enterprise_entity.dart';

abstract class EnterpriseRepository {
  Future<Either<Failure, List<EnterpriseEntity>>> getEnterprises({
    String? search,
    Sector? sector,
  });
  
  Future<Either<Failure, EnterpriseEntity>> getEnterpriseById(String id);
  
  Future<Either<Failure, EnterpriseEntity>> registerEnterprise(Map<String, dynamic> data);
  
  Future<Either<Failure, EnterpriseEntity>> updateEnterprise(String id, Map<String, dynamic> data);
}
