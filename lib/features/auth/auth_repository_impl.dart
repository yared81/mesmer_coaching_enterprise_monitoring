import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/secure_storage.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_repository.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_token_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_remote_datasource.dart';

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
      
      // Cache the user for offline access
      await _secureStorage.saveUserProfile(jsonEncode(userModel.toJson()));
      
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Clear local session first so the user can always log out offline
    await _secureStorage.clearTokens();
    await _secureStorage.clearUserProfile();

    try {
      await _remoteDatasource.logout();
      return const Right(null);
    } catch (e) {
      final failure = Failure.fromException(e);
      // If it's a network error, we don't care, we still consider the local logout successful
      if (failure is NetworkFailure) {
        return const Right(null);
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await _remoteDatasource.getMe();
      // Cache the user for offline access
      await _secureStorage.saveUserProfile(jsonEncode(userModel.toJson()));
      return Right(userModel.toEntity());
    } catch (e) {
      final failure = Failure.fromException(e);
      
      // If it's a network failure, try to load from offline cache
      if (failure is NetworkFailure) {
        try {
          final cachedUserJson = await _secureStorage.getUserProfile();
          if (cachedUserJson != null) {
            final userMap = jsonDecode(cachedUserJson) as Map<String, dynamic>;
            final cachedUserModel = UserModel.fromJson(userMap);
            return Right(cachedUserModel.toEntity());
          }
        } catch (_) {
          // If parsing fails, fall through to returning the original failure
        }
      }
      
      return Left(failure);
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
      
      // Update the local cache
      await _secureStorage.saveUserProfile(jsonEncode(userModel.toJson()));
      
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}
