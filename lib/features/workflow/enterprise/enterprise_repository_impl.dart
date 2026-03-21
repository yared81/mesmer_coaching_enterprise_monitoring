import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
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
  }) async {
    try {
      final models = await _remoteDatasource.getEnterprises(
        search: search,
        sector: sector,
        status: status,
      );
      return Right(models.map((m) => EnterpriseModel.fromJson(m).toEntity()).toList());
    } catch (e) {
      return Left(Failure.fromException(e));
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
      final map = await _remoteDatasource.getEnterpriseDashboardStats();
      return Right(EnterpriseDashboardModel.fromJson(map));
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}
