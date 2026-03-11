import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}
