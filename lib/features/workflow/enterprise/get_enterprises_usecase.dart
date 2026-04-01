import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'enterprise_entity.dart';
import 'enterprise_repository.dart';

class GetEnterprisesUseCase {
  GetEnterprisesUseCase(this._repository);
  final EnterpriseRepository _repository;

  Future<Either<Failure, List<EnterpriseEntity>>> call({
    String? search,
    String? sector,
    String? status,
    String? coachId,
  }) async {
    return _repository.getEnterprises(search: search, sector: sector, status: status, coachId: coachId);
  }
}
