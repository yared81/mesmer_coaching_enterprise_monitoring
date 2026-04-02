import 'dart:convert';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/db/local_database.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'coaching_session_entity.dart';
import 'coaching_repository.dart';
import 'coaching_remote_datasource.dart';
import 'coaching_session_model.dart';
import 'phone_followup_entity.dart';
import 'phone_followup_model.dart';

import 'dart:convert';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/db/local_database.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'package:mesmer_digital_coaching/core/network/offline_provider.dart';
import 'coaching_session_entity.dart';
import 'coaching_repository.dart';
import 'coaching_remote_datasource.dart';
import 'coaching_session_model.dart';
import 'phone_followup_entity.dart';
import 'phone_followup_model.dart';

class CoachingRepositoryImpl implements CoachingRepository {
  final CoachingRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;
  final OfflineModeNotifier offlineNotifier;

  CoachingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
    required this.offlineNotifier,
  });

  String _generateOfflineId() {
    return 'off_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  @override
  Future<Either<Failure, CoachingSessionEntity>> createSession(CoachingSessionEntity session) async {
    if (offlineNotifier.state) {
      return _localCreateSession(session);
    }

    try {
      final model = CoachingSessionModel.fromEntity(session);
      final result = await remoteDataSource.createSession(model);
      await localDatabase.saveSession(result.id, result.toJson());
      return Right(result);
    } catch (e) {
      return _localCreateSession(session);
    }
  }

  Future<Either<Failure, CoachingSessionEntity>> _localCreateSession(CoachingSessionEntity session) async {
    final finalId = session.id.isEmpty ? _generateOfflineId() : session.id;
    final model = CoachingSessionModel.fromEntity(session).copyWith(id: finalId);
    final data = model.toJson();
    
    await localDatabase.saveSession(finalId, data);
    await localDatabase.enqueueSyncAction('POST', 'coaching-sessions', jsonEncode(data));
    
    return Right(model);
  }

  @override
  Future<Either<Failure, List<CoachingSessionEntity>>> getMySessions() async {
    if (offlineNotifier.state) {
      // For now, we don't have a 'getMySessions' local filter, 
      // but we can return empty or allcached if needed.
      return const Right([]); 
    }

    try {
      final result = await remoteDataSource.getMySessions();
      for (var s in result) {
        await localDatabase.saveSession(s.id, (s as CoachingSessionModel).toJson());
      }
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<CoachingSessionEntity>>> getEnterpriseSessions(String enterpriseId) async {
    if (offlineNotifier.state) {
      return _localGetEnterpriseSessions(enterpriseId);
    }

    try {
      final result = await remoteDataSource.getEnterpriseSessions(enterpriseId);
      for (var s in result) {
        await localDatabase.saveSession(s.id, (s as CoachingSessionModel).toJson());
      }
      return Right(result);
    } catch (e) {
      return _localGetEnterpriseSessions(enterpriseId);
    }
  }

  Future<Either<Failure, List<CoachingSessionEntity>>> _localGetEnterpriseSessions(String enterpriseId) async {
    try {
      final localData = await localDatabase.getSessionsByEnterprise(enterpriseId);
      return Right(localData.map((m) => CoachingSessionModel.fromJson(m)).toList());
    } catch (e) {
      return Left(LocalFailure(message: 'Offline sessions unavailable'));
    }
  }

  @override
  Future<Either<Failure, CoachingSessionEntity>> updateSession(CoachingSessionEntity session) async {
    if (offlineNotifier.state) {
      return _localUpdateSession(session);
    }

    try {
      final model = CoachingSessionModel.fromEntity(session);
      final result = await remoteDataSource.updateSession(model);
      await localDatabase.saveSession(result.id, result.toJson());
      return Right(result);
    } catch (e) {
      return _localUpdateSession(session);
    }
  }

  Future<Either<Failure, CoachingSessionEntity>> _localUpdateSession(CoachingSessionEntity session) async {
    final model = CoachingSessionModel.fromEntity(session);
    final data = model.toJson();
    
    await localDatabase.saveSession(session.id, data);
    await localDatabase.enqueueSyncAction('PUT', 'coaching-sessions/${session.id}', jsonEncode(data));
    
    return Right(model);
  }

  @override
  Future<Either<Failure, PhoneFollowupEntity>> createPhoneFollowup(PhoneFollowupEntity log) async {
    // Basic connectivity check fallback
    try {
      if (!offlineNotifier.state) {
        final model = PhoneFollowupModel.fromEntity(log);
        final result = await remoteDataSource.createPhoneFollowup(model);
        return Right(result);
      }
      throw Exception('Offline mode active');
    } catch (e) {
      final finalId = log.id.isEmpty ? _generateOfflineId() : log.id;
      final model = PhoneFollowupModel.fromEntity(log).copyWith(id: finalId);
      await localDatabase.enqueueSyncAction('POST', 'phone-followups', jsonEncode(model.toJson()));
      return Right(model);
    }
  }

  @override
  Future<Either<Failure, List<PhoneFollowupEntity>>> getCoachPhoneFollowups() async {
    try {
      final result = await remoteDataSource.getCoachPhoneFollowups();
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<PhoneFollowupEntity>>> getEnterprisePhoneFollowups(String enterpriseId) async {
    try {
      final result = await remoteDataSource.getEnterprisePhoneFollowups(enterpriseId);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}
