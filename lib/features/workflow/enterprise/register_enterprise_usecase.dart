import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'enterprise_entity.dart';
import 'enterprise_repository.dart';

class RegisterEnterpriseUseCase {
  RegisterEnterpriseUseCase(this._repository);
  final EnterpriseRepository _repository;

  Future<Either<Failure, EnterpriseEntity>> call(Map<String, dynamic> data) async {
    return _repository.registerEnterprise(data);
  }
}
