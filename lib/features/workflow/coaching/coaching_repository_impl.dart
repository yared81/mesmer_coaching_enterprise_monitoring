import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'coaching_session_entity.dart';
import 'coaching_repository.dart';
import 'coaching_remote_datasource.dart';
import 'coaching_session_model.dart';
import 'phone_followup_entity.dart';
import 'phone_followup_model.dart';

class CoachingRepositoryImpl implements CoachingRepository {
  final CoachingRemoteDataSource remoteDataSource;

  CoachingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CoachingSessionEntity>> createSession(CoachingSessionEntity session) async {
    try {
      final model = CoachingSessionModel(
        id: session.id,
        title: session.title,
        enterpriseId: session.enterpriseId,
        coachId: session.coachId,
        scheduledDate: session.scheduledDate,
        status: session.status,
        sessionNumber: session.sessionNumber,
        followupType: session.followupType,
        revenueGrowthPercent: session.revenueGrowthPercent,
        currentEmployees: session.currentEmployees,
        jobsCreated: session.jobsCreated,
        qcStatus: session.qcStatus,
        templateId: session.templateId,
        enterpriseName: session.enterpriseName,
        problemsIdentified: session.problemsIdentified,
        recommendations: session.recommendations,
        notes: session.notes,
      );
      final result = await remoteDataSource.createSession(model);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<CoachingSessionEntity>>> getMySessions() async {
    try {
      final result = await remoteDataSource.getMySessions();
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<CoachingSessionEntity>>> getEnterpriseSessions(String enterpriseId) async {
    try {
      final result = await remoteDataSource.getEnterpriseSessions(enterpriseId);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, CoachingSessionEntity>> updateSession(CoachingSessionEntity session) async {
    try {
      final model = CoachingSessionModel(
        id: session.id,
        title: session.title,
        enterpriseId: session.enterpriseId,
        coachId: session.coachId,
        scheduledDate: session.scheduledDate,
        status: session.status,
        sessionNumber: session.sessionNumber,
        followupType: session.followupType,
        revenueGrowthPercent: session.revenueGrowthPercent,
        currentEmployees: session.currentEmployees,
        jobsCreated: session.jobsCreated,
        qcStatus: session.qcStatus,
        templateId: session.templateId,
        enterpriseName: session.enterpriseName,
        problemsIdentified: session.problemsIdentified,
        recommendations: session.recommendations,
        notes: session.notes,
      );
      final result = await remoteDataSource.updateSession(model);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PhoneFollowupEntity>> createPhoneFollowup(PhoneFollowupEntity log) async {
    try {
      final model = PhoneFollowupModel(
        id: log.id,
        enterpriseId: log.enterpriseId,
        coachId: log.coachId,
        date: log.date,
        purpose: log.purpose,
        issueAddressed: log.issueAddressed,
        adviceGiven: log.adviceGiven,
        nextAction: log.nextAction,
      );
      final result = await remoteDataSource.createPhoneFollowup(model);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
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
