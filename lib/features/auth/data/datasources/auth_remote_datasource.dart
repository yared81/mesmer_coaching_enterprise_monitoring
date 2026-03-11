// TODO: Implement auth API calls against Node.js backend
// Endpoints (see ApiConstants): POST /auth/login, POST /auth/logout,
// POST /auth/refresh, GET /auth/me, POST /auth/forgot-password

import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);
  final Dio _dio;

  // TODO: Future<Map<String, dynamic>> login(String email, String password)
  // TODO: Future<void> logout()
  // TODO: Future<Map<String, dynamic>> refreshToken(String refreshToken)
  // TODO: Future<Map<String, dynamic>> getMe()
  // TODO: Future<void> forgotPassword(String email)
}
