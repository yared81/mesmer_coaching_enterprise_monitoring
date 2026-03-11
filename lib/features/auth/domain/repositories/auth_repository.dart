// TODO: Auth repository interface (contract for the domain layer)
// Implemented by AuthRepositoryImpl in the data layer

import '../entities/user_entity.dart';

abstract class AuthRepository {
  // TODO: Future<Either<Failure, UserEntity>> login(String email, String password)
  // TODO: Future<Either<Failure, void>> logout()
  // TODO: Future<Either<Failure, UserEntity>> getCurrentUser()
  // TODO: Future<Either<Failure, void>> forgotPassword(String email)
}
