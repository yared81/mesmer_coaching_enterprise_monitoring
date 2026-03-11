// TODO: Define Failure sealed classes for the domain layer (used with dartz Either)
// Examples: ServerFailure, NetworkFailure, CacheFailure, UnauthorizedFailure

abstract class Failure {
  final String message;
  const Failure(this.message);
}

// TODO: Add specific Failure subclasses
