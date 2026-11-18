import 'package:dio/dio.dart';

import '../../database/secure/secure_storage.dart';

/// Adds the bearer token unless the request opts out with `extra: {'token': false}`.
class RequestInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['token'] != false) {
      final t = await SecureStorage().getAccessToken();
      if (t != null) options.headers['Authorization'] = 'Bearer $t';
    }
    handler.next(options);
  }
}
