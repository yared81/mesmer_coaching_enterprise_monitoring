import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'package:mesmer_digital_coaching/features/auth/user_entity.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return _repository.login(email, password);
  }
}
