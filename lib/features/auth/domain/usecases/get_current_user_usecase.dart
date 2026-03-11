import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/entities/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call() {
    return _repository.getCurrentUser();
  }
}
