import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/enterprise_entity.dart';
import '../repositories/enterprise_repository.dart';

class UpdateEnterpriseUseCase {
  UpdateEnterpriseUseCase(this._repository);
  final EnterpriseRepository _repository;

  Future<Either<Failure, EnterpriseEntity>> call(String id, Map<String, dynamic> data) {
    return _repository.updateEnterprise(id, data);
  }
}
