import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/coach_entity.dart';
import '../repositories/coach_repository.dart';

class GetCoachesUseCase {
  final CoachRepository repository;

  GetCoachesUseCase(this.repository);

  Future<Either<Failure, List<CoachEntity>>> call() async {
    return await repository.getCoaches();
  }
}

class RegisterCoachUseCase {
  final CoachRepository repository;

  RegisterCoachUseCase(this.repository);

  Future<Either<Failure, CoachEntity>> call(String name, String email, String phone) async {
    return await repository.registerCoach(name, email, phone);
  }
}
