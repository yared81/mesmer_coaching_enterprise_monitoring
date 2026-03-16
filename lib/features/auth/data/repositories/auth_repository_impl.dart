import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/secure_storage.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/entities/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/repositories/auth_repository.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/data/models/auth_token_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/data/models/user_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/data/datasources/auth_remote_datasource.dart';

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
      final responseData = await _remoteDatasource.login(email, password);
      
      final tokenModel = AuthTokenModel.fromJson(responseData);
      await _secureStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );
      
      final userData = responseData['user'];
      if (userData == null) {
        return Left(ServerFailure(message: 'User data missing from response'));
      }

      final userModel = UserModel.fromJson(userData as Map<String, dynamic>);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDatasource.logout();
      await _secureStorage.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await _remoteDatasource.getMe();
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remoteDatasource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(String name, String email) async {
    try {
      final userModel = await _remoteDatasource.updateProfile(name, email);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}
