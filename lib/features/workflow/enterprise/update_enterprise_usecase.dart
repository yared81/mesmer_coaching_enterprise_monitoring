import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'enterprise_entity.dart';
import 'enterprise_repository.dart';

class UpdateEnterpriseUseCase {
  UpdateEnterpriseUseCase(this._repository);
  final EnterpriseRepository _repository;

  Future<Either<Failure, EnterpriseEntity>> call(String id, Map<String, dynamic> data) {
    return _repository.updateEnterprise(id, data);
  }
}
