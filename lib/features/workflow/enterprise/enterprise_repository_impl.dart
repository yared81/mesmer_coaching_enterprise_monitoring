import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/storage/hive_storage.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'package:mesmer_digital_coaching/core/network/offline_provider.dart';
import 'package:mesmer_digital_coaching/core/db/local_database.dart';
import 'enterprise_entity.dart';
import 'enterprise_repository.dart';
import 'enterprise_remote_datasource.dart';
import 'enterprise_model.dart';
import 'enterprise_dashboard_stats.dart';
import 'enterprise_dashboard_model.dart';

class EnterpriseRepositoryImpl implements EnterpriseRepository {
  EnterpriseRepositoryImpl(this._remoteDatasource, this._localDatabase, this._offlineNotifier);
  final EnterpriseRemoteDatasource _remoteDatasource;
  final LocalDatabase _localDatabase;
  final OfflineModeNotifier _offlineNotifier;

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
      // Cache for offline use
      for (var m in models) {
        await _localDatabase.saveEnterprise(m['id'], m);
      }
      return Right(models.map((m) => EnterpriseModel.fromJson(m).toEntity()).toList());
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        return _localGetEnterprises();
      }
      return Left(Failure.fromException(e));
    } catch (e) {
      return _localGetEnterprises();
    }
  }

  Future<Either<Failure, List<EnterpriseEntity>>> _localGetEnterprises() async {
    try {
      final localData = await _localDatabase.getEnterprises();
      return Right(localData.map((m) => EnterpriseModel.fromJson(m).toEntity()).toList());
    } catch (e) {
      return Left(LocalFailure(message: 'Offline data unavailable'));
    }
  }

  @override
  Future<Either<Failure, EnterpriseEntity>> getEnterpriseById(String id) async {
    try {
      final map = await _remoteDatasource.getEnterpriseById(id);
      await _localDatabase.saveEnterprise(id, map);
      return Right(EnterpriseModel.fromJson(map).toEntity());
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        final local = await _localDatabase.getEnterpriseById(id);
        if (local != null) return Right(EnterpriseModel.fromJson(local).toEntity());
      }
      return Left(Failure.fromException(e));
    } catch (e) {
      final local = await _localDatabase.getEnterpriseById(id);
      if (local != null) return Right(EnterpriseModel.fromJson(local).toEntity());
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, EnterpriseEntity>> registerEnterprise(Map<String, dynamic> data) async {
    try {
      final map = await _remoteDatasource.createEnterprise(data);
      await _localDatabase.saveEnterprise(map['id'], map);
      return Right(EnterpriseModel.fromJson(map).toEntity());
    } on DioException catch (e) {
      if (_isConnectionError(e)) return _localRegister(data);
      return Left(Failure.fromException(e));
    } catch (e) {
      return _localRegister(data);
    }
  }

  Future<Either<Failure, EnterpriseEntity>> _localRegister(Map<String, dynamic> data) async {
    // Generate a temporary ID (prefixed with 'off_') for offline records
    final id = 'off_${DateTime.now().millisecondsSinceEpoch}';
    final fullData = {...data, 'id': id, 'is_offline': true};
    
    await _localDatabase.saveEnterprise(id, fullData);
    await _localDatabase.enqueueSyncAction('POST', 'enterprises', jsonEncode(data));
    
    return Right(EnterpriseModel.fromJson(fullData).toEntity());
  }

  @override
  Future<Either<Failure, EnterpriseEntity>> updateEnterprise(String id, Map<String, dynamic> data) async {
    try {
      final map = await _remoteDatasource.updateEnterprise(id, data);
      await _localDatabase.saveEnterprise(id, map);
      return Right(EnterpriseModel.fromJson(map).toEntity());
    } on DioException catch (e) {
      if (_isConnectionError(e)) return _localUpdate(id, data);
      return Left(Failure.fromException(e));
    } catch (e) {
      return _localUpdate(id, data);
    }
  }

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }

  Future<Either<Failure, EnterpriseEntity>> _localUpdate(String id, Map<String, dynamic> data) async {
    final existing = await _localDatabase.getEnterpriseById(id);
    if (existing == null) return Left(LocalFailure(message: 'Record not found locally'));

    final updated = {...existing, ...data};
    await _localDatabase.saveEnterprise(id, updated);
    await _localDatabase.enqueueSyncAction('PUT', 'enterprises/$id', jsonEncode(data));

    return Right(EnterpriseModel.fromJson(updated).toEntity());
  }

  @override
  Future<Either<Failure, EnterpriseDashboardStats>> getEnterpriseDashboardStats() async {
    try {
      final data = await _remoteDatasource.getEnterpriseDashboardStats();
      return Right(EnterpriseDashboardStats.fromJson(data));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Genuine offline — fall through to local
      } else {
        return Left(Failure.fromException(e));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }

    // Offline fallback — build minimal stats from local cache
    final enterprises = await _localDatabase.getEnterprises();
    return Right(EnterpriseDashboardStats(
      enterpriseId: '',
      businessName: '',
      sector: '',
      radarScores: [],
      latestRecommendation: '',
      totalSessions: 0,
    ));
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
