import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/storage/hive_storage.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'enterprise_entity.dart';
import 'enterprise_repository.dart';
import 'enterprise_remote_datasource.dart';
import 'enterprise_model.dart';
import 'enterprise_dashboard_stats.dart';
import 'enterprise_dashboard_model.dart';

class EnterpriseRepositoryImpl implements EnterpriseRepository {
  EnterpriseRepositoryImpl(this._remoteDatasource);
  final EnterpriseRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, List<EnterpriseEntity>>> getEnterprises({
    String? search,
    String? sector,
    String? status,
    String? coachId,
  }) async {
    try {
      final models = await _remoteDatasource.getEnterprises(
        search: search,
        sector: sector,
        status: status,
        coachId: coachId,
      );
      
      // Save full array to cache
      final jsonList = models.map((m) => EnterpriseModel.fromJson(m).toJson()).toList();
      await HiveStorage.cacheEnterprises('default_list', jsonEncode(jsonList));

      return Right(models.map((m) => EnterpriseModel.fromJson(m).toEntity()).toList());
    } catch (e) {
      final failure = Failure.fromException(e);
      if (failure is NetworkFailure) {
        try {
          final cachedString = HiveStorage.getCachedEnterprises('default_list');
          if (cachedString != null) {
            final List<dynamic> jsonList = jsonDecode(cachedString);
            final cachedModels = jsonList.map((m) => EnterpriseModel.fromJson(m as Map<String, dynamic>)).toList();
            return Right(cachedModels.map((m) => m.toEntity()).toList());
          }
        } catch (_) {}
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, EnterpriseEntity>> getEnterpriseById(String id) async {
    try {
      final map = await _remoteDatasource.getEnterpriseById(id);
      return Right(EnterpriseModel.fromJson(map).toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, EnterpriseEntity>> registerEnterprise(Map<String, dynamic> data) async {
    try {
      final map = await _remoteDatasource.createEnterprise(data);
      return Right(EnterpriseModel.fromJson(map).toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, EnterpriseEntity>> updateEnterprise(String id, Map<String, dynamic> data) async {
    try {
      final map = await _remoteDatasource.updateEnterprise(id, data);
      return Right(EnterpriseModel.fromJson(map).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnterpriseDashboardStats>> getEnterpriseDashboardStats() async {
    try {
      final data = await _remoteDatasource.getEnterpriseDashboardStats();
      return Right(EnterpriseDashboardStats.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EnterpriseEntity>>> bulkRegister(List<Map<String, dynamic>> enterprises) async {
    try {
      final result = await _remoteDatasource.bulkCreateEnterprises(enterprises);
      return Right(result.map((m) => EnterpriseModel.fromJson(m).toEntity()).toList());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getEnterpriseTrends(String id) async {
    try {
      final data = await _remoteDatasource.getEnterpriseTrends(id);
      return Right(data.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
