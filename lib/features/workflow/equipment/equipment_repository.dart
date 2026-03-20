import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import 'equipment_entity.dart';
import 'equipment_model.dart';

abstract class EquipmentRepository {
  Future<Either<Failure, List<EquipmentEntity>>> getEnterpriseAssets(String enterpriseId);
  Future<Either<Failure, EquipmentEntity>> addAsset(EquipmentEntity asset);
  Future<Either<Failure, EquipmentEntity>> updateStatus(String id, EquipmentStatus status, String? notes);
}

class EquipmentRepositoryImpl implements EquipmentRepository {
  final Dio _dio;
  EquipmentRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, List<EquipmentEntity>>> getEnterpriseAssets(String enterpriseId) async {
    try {
      final response = await _dio.get('/api/v1/equipment/enterprise/$enterpriseId');
      final list = (response.data['data'] as List).map((j) => EquipmentModel.fromJson(j)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Fetch failed'));
    }
  }

  @override
  Future<Either<Failure, EquipmentEntity>> addAsset(EquipmentEntity asset) async {
    try {
      final model = EquipmentModel(
        id: '',
        name: asset.name,
        serialNumber: asset.serialNumber,
        enterpriseId: asset.enterpriseId,
        receivedDate: asset.receivedDate,
        notes: asset.notes,
      );
      final response = await _dio.post('/api/v1/equipment', data: model.toJson());
      return Right(EquipmentModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Addition failed'));
    }
  }

  @override
  Future<Either<Failure, EquipmentEntity>> updateStatus(String id, EquipmentStatus status, String? notes) async {
    try {
      final response = await _dio.put('/api/v1/equipment/$id/status', data: {
        'status': status.name,
        'notes': notes
      });
      return Right(EquipmentModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Update failed'));
    }
  }
}
