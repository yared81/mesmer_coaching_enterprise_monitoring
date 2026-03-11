import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/enterprise_entity.dart';
import '../repositories/enterprise_repository.dart';

class GetEnterprisesUseCase {
  GetEnterprisesUseCase(this._repository);
  final EnterpriseRepository _repository;

  Future<Either<Failure, List<EnterpriseEntity>>> call({
    String? search,
    Sector? sector,
  }) async {
    return _repository.getEnterprises(search: search, sector: sector);
  }
}
