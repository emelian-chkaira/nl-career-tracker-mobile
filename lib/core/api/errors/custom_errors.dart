import 'package:dio/dio.dart';

enum ErrorType { badRequest, unauthorized, forbidden, notFound, conflict, validation, tooManyRequests, server, noInternet, unknown }

/// The one exception type cubits ever see. Built from DioException by the error interceptor.
class CustomDioException extends DioException {
  final ErrorType errorType;
  @override
  final String? message;

  CustomDioException(RequestOptions r, Response<dynamic>? response, this.errorType, [this.message]) : super(requestOptions: r, response: response);

  factory CustomDioException.fromDioError(DioException e) {
    final status = e.response?.statusCode;
    final server = _detail(e.response?.data);
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return CustomDioException(e.requestOptions, e.response, ErrorType.noInternet, 'Cannot reach the server. Check your connection.');
      default:
    }
    final (type, fallback) = switch (status) {
      400 => (ErrorType.badRequest, 'Invalid request'),
      401 => (ErrorType.unauthorized, 'Please sign in again'),
      403 => (ErrorType.forbidden, 'You do not have access to this'),
      404 => (ErrorType.notFound, 'Not found'),
      409 => (ErrorType.conflict, 'Conflict'),
      422 => (ErrorType.validation, 'Please check the entered data'),
      429 => (ErrorType.tooManyRequests, 'Too many requests, slow down a little'),
      final int s when s >= 500 => (ErrorType.server, 'Server error, try again later'),
      _ => (ErrorType.unknown, 'Something went wrong'),
    };
    return CustomDioException(e.requestOptions, e.response, type, server ?? fallback);
  }

  static String? _detail(dynamic data) {
    if (data is Map && data['detail'] != null) {
      final d = data['detail'];
      if (d is String) return d;
      if (d is Map && d['error'] is String) return d['error'] as String;
      if (d is List) return d.map((x) => x is Map ? x['msg'] : x).whereType<String>().join('; ');
    }
    return null;
  }

  @override
  String toString() => 'CustomDioException($errorType: $message)';
}
