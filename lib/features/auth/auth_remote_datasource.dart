import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_token_model.dart';
import 'package:mesmer_digital_coaching/features/auth/user_model.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.refresh,
      data: {'refreshToken': refreshToken},
    );
    return AuthTokenModel.fromJson(response.data);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.me);
    return UserModel.fromJson(response.data['user']);
  }

  Future<UserModel> updateProfile(String name, String email) async {
    final response = await _dio.put(
      'auth/profile',
      data: {'name': name, 'email': email},
    );
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      'auth/forgot-password',
      data: {'email': email},
    );
  }
}
