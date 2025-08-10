/// Base exception class for the application
abstract class AppException implements Exception {
  
  const AppException(this.message, {this.code});
  final String message;
  final String? code;
  
  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when a server error occurs
class ServerException extends AppException {
  
  const ServerException(super.message, {this.statusCode, super.code});
  final int? statusCode;
  
  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Exception thrown when a network error occurs
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when a cache error occurs
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
  
  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  
  const ValidationException(super.message, {this.errors, super.code});
  final Map<String, List<String>>? errors;
  
  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when location services are not available
class LocationException extends AppException {
  const LocationException(super.message, {super.code});
  
  @override
  String toString() => 'LocationException: $message';
}

/// Exception thrown when permission is denied
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
  
  @override
  String toString() => 'PermissionException: $message';
}
