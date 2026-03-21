import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/admin/institution_model.dart';

abstract class UserManagementRepository {
  Future<Either<String, List<UserModel>>> getUsers({String? role, String? institutionId, String? search});
  Future<Either<String, UserModel>> createUser(Map<String, dynamic> userData);
  Future<Either<String, UserModel>> updateUser(String userId, Map<String, dynamic> userData);
  Future<Either<String, bool>> toggleUserStatus(String userId);
  Future<Either<String, List<InstitutionModel>>> getInstitutions();
}

class UserManagementRepositoryImpl implements UserManagementRepository {
  final Dio _dio;

  UserManagementRepositoryImpl(this._dio);

  @override
  Future<Either<String, List<UserModel>>> getUsers({String? role, String? institutionId, String? search}) async {
    try {
      final response = await _dio.get(
        ApiConstants.userManagement,
        queryParameters: {
          if (role != null) 'role': role,
          if (institutionId != null) 'institution_id': institutionId,
          if (search != null) 'search': search,
        },
      );
      
      final List users = response.data['data'];
      return Right(users.map((e) => UserModel.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserModel>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(ApiConstants.userManagement, data: userData);
      return Right(UserModel.fromJson(response.data['data']));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserModel>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('${ApiConstants.userManagement}/$userId', data: userData);
      return Right(UserModel.fromJson(response.data['data']));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> toggleUserStatus(String userId) async {
    try {
      final response = await _dio.patch('${ApiConstants.userManagement}/$userId/toggle-status');
      return Right(response.data['data']['is_active']);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<InstitutionModel>>> getInstitutions() async {
    try {
      final response = await _dio.get(ApiConstants.institutions);
      final List institutions = response.data['data'];
      return Right(institutions.map((e) => InstitutionModel.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }
}
