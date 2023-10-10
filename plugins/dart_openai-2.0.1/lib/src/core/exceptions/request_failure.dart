import 'package:meta/meta.dart';

/// {@template request_failure}
/// This exception is thrown when a request fails, from the API.
/// {@endtemplate}
@immutable
class RequestFailedException implements Exception {
  /// The error message of the request that failed, if any.
  final String message;

  /// The status code of the request that failed, if any.
  final int statusCode;

  /// {@macro request_failure}
  RequestFailedException(this.message, this.statusCode);

  @override
  String toString() {
    return 'RequestFailedException{message: $message, statusCode: $statusCode}';
  }
}
