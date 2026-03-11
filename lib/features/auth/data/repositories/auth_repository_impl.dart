import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required SecureStorage secureStorage,
  })  : _remoteDatasource = remoteDatasource,
        _secureStorage = secureStorage;

  final AuthRemoteDatasource _remoteDatasource;
  final SecureStorage _secureStorage;

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final tokenModel = await _remoteDatasource.login(email, password);
      await _secureStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );
      final userModel = await _remoteDatasource.getMe();
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDatasource.logout();
      await _secureStorage.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await _remoteDatasource.getMe();
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remoteDatasource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
