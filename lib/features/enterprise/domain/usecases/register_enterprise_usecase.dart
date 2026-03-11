import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/enterprise_entity.dart';
import '../repositories/enterprise_repository.dart';

class RegisterEnterpriseUseCase {
  RegisterEnterpriseUseCase(this._repository);
  final EnterpriseRepository _repository;

  Future<Either<Failure, EnterpriseEntity>> call(Map<String, dynamic> data) async {
    return _repository.registerEnterprise(data);
  }
}
