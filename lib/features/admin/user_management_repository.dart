import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/features/auth/user_model.dart';
import 'package:mesmer_digital_coaching/features/admin/institution_model.dart';

abstract class UserManagementRepository {
  Future<Either<String, List<UserModel>>> getUsers({String? role, String? institutionId, String? search});
  Future<Either<String, UserModel>> createUser(Map<String, dynamic> userData);
  Future<Either<String, UserModel>> updateUser(String userId, Map<String, dynamic> userData);
  Future<Either<String, bool>> toggleUserStatus(String userId);
  Future<Either<String, List<InstitutionModel>>> getInstitutions({String? parentId, bool? isRoot});
  Future<Either<String, InstitutionModel>> createInstitution(Map<String, dynamic> data);
  Future<Either<String, InstitutionModel>> updateInstitution(String id, Map<String, dynamic> data);
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
  Future<Either<String, List<InstitutionModel>>> getInstitutions({String? parentId, bool? isRoot}) async {
    try {
      final response = await _dio.get(
        ApiConstants.institutions,
        queryParameters: {
          if (parentId != null) 'parentId': parentId,
          if (isRoot != null) 'isRoot': isRoot.toString(),
        },
      );
      final List institutions = response.data['data'];
      return Right(institutions.map((e) => InstitutionModel.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, InstitutionModel>> createInstitution(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.institutions, data: data);
      return Right(InstitutionModel.fromJson(response.data['data']));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, InstitutionModel>> updateInstitution(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConstants.institutions}/$id', data: data);
      return Right(InstitutionModel.fromJson(response.data['data']));
    } catch (e) {
      return Left(e.toString());
    }
  }
}
