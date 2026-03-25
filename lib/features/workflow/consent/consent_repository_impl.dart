import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/network/dio_client.dart';
import 'consent_record_entity.dart';
import 'consent_record_model.dart';
import 'consent_repository.dart';

class ConsentRepositoryImpl implements ConsentRepository {
  final Dio _dio;

  ConsentRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, ConsentRecordEntity>> createConsent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/v1/consent', data: data);
      if (response.data['success']) {
        return Right(ConsentRecordModel.fromJson(response.data['data']));
      } else {
        return Left(ServerFailure(message: response.data['message'] ?? 'Failed to create consent'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConsentRecordEntity?>> getConsentByEnterprise(String enterpriseId) async {
    try {
      final response = await _dio.get('/api/v1/consent/$enterpriseId');
      if (response.data['success'] && response.data['data'] != null) {
        return Right(ConsentRecordModel.fromJson(response.data['data']));
      } else {
        return const Right(null);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right(null);
      }
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConsentRecordEntity>>> listConsents() async {
    try {
      final response = await _dio.get('/api/v1/consent');
      if (response.data['success']) {
        final List data = response.data['data'];
        return Right(data.map((e) => ConsentRecordModel.fromJson(e)).toList());
      } else {
        return Left(ServerFailure(message: response.data['message'] ?? 'Failed to list consents'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
