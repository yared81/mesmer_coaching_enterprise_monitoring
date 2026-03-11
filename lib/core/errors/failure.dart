abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server Error'}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No Internet Connection'}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache Error'}) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({String message = 'Unauthorized'}) : super(message);
}
