class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.statusCode, [this.message = 'An error occurred']);

  @override
  String toString() {
    return 'ApiException: HTTP $statusCode - $message';
  }
}

class NetworkException extends ApiException {
  const NetworkException([String message = 'Network error occurred'])
    : super(null, message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Unauthorized'])
    : super(401, message);
}

class ValidationException extends ApiException {
  final dynamic errors;
  const ValidationException([String message = 'Validation failed', this.errors])
    : super(400, message);
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Resource not found'])
    : super(404, message);
}

class ConflictException extends ApiException {
  const ConflictException([String message = 'Conflict occurred'])
    : super(409, message);
}

class ServerException extends ApiException {
  const ServerException([String message = 'Server error'])
    : super(500, message);
}

class DatabaseException implements Exception {
  final String message;

  const DatabaseException([this.message = 'An error occurred']);

  @override
  String toString() {
    return 'Database Exception: $message';
  }
}
