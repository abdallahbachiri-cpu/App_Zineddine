import 'package:cuisinous/core/errors/exceptions.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ApiFailure extends Failure {
  final int? statusCode;
  const ApiFailure(super.message, this.statusCode);

  factory ApiFailure.fromException(ApiException e) {
    return ApiFailure(e.message, e.statusCode);
  }
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);

  factory DatabaseFailure.fromException(DatabaseException e) {
    return DatabaseFailure(e.toString());
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  final StackTrace stackTrace;
  UnknownFailure(dynamic e, this.stackTrace)
    : super('Unknown error: ${e?.toString() ?? 'No error message'}');
}

abstract class ConnectivityWrapper {
  Future<bool> get isConnected;
}

class NullTokenFailure extends Failure {
  NullTokenFailure() : super('Received null token after refresh');
}
