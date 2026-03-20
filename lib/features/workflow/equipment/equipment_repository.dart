import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/db/local_cache_repository.dart';
import 'equipment_entity.dart';
import 'equipment_model.dart';

abstract class EquipmentRepository {
  Future<Either<Failure, List<EquipmentEntity>>> getEnterpriseAssets(String enterpriseId);
  Future<Either<Failure, EquipmentEntity>> addAsset(EquipmentEntity asset);
  Future<Either<Failure, EquipmentEntity>> updateStatus(String id, EquipmentStatus status, String? notes);
}

class EquipmentRepositoryImpl implements EquipmentRepository {
  final Dio _dio;
  final LocalCacheRepository _cache;
  EquipmentRepositoryImpl(this._dio, this._cache);

  @override
  Future<Either<Failure, List<EquipmentEntity>>> getEnterpriseAssets(String enterpriseId) async {
    try {
      final response = await _dio.get('/api/v1/equipment/enterprise/$enterpriseId');
      final list = (response.data['data'] as List).map((j) => EquipmentModel.fromJson(j)).toList();
      await _cache.cacheEnterpriseEquipment(enterpriseId, response.data['data'] as List<Map<String, dynamic>>);
      return Right(list);
    } on DioException catch (e) {
      final cached = await _cache.getCachedEnterpriseEquipment(enterpriseId);
      if (cached.isNotEmpty) {
        return Right(cached.map((j) => EquipmentModel.fromJson(j)).toList());
      }
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Fetch failed'));
    }
  }

  @override
  Future<Either<Failure, EquipmentEntity>> addAsset(EquipmentEntity asset) async {
    final model = EquipmentModel(
      id: '',
      name: asset.name,
      serialNumber: asset.serialNumber,
      enterpriseId: asset.enterpriseId,
      receivedDate: asset.receivedDate,
      notes: asset.notes,
    );

    try {
      final response = await _dio.post('/api/v1/equipment', data: model.toJson());
      return Right(EquipmentModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      if (e.type != DioExceptionType.badResponse) {
        await _cache.enqueueSyncAction('POST', '/api/v1/equipment', model.toJson());
        return Right(asset);
      }
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Addition failed'));
    }
  }

  @override
  Future<Either<Failure, EquipmentEntity>> updateStatus(String id, EquipmentStatus status, String? notes) async {
    final payload = {'status': status.name, 'notes': notes};
    try {
      final response = await _dio.put('/api/v1/equipment/$id/status', data: payload);
      return Right(EquipmentModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      if (e.type != DioExceptionType.badResponse) {
        await _cache.enqueueSyncAction('PUT', '/api/v1/equipment/$id/status', payload);
        // Best effort: we don't return the full updated model but at least enqueued
        return Left(CacheFailure(message: 'Enqueued for sync (Offline)'));
      }
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Update failed'));
    }
  }
}

