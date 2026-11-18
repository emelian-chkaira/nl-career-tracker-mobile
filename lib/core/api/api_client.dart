import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../logging/app_talker.dart';
import 'endpoints.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import 'interceptors/request_interceptor.dart';

enum HttpMethod { get, post, put, patch, delete }

/// Singleton Dio client. Repos call [request]; cubits never touch Dio.
class ApiClient {
  ApiClient._();
  static final ApiClient _singleton = ApiClient._();
  factory ApiClient() => _singleton;

  void Function()? onSessionExpired;

  late final Dio dio = _create();

  Dio _create() {
    final d = Dio(BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Accept': 'application/json'},
    ));
    d.interceptors.addAll([
      RequestInterceptor(),
      RefreshInterceptor(d, onSessionExpired: () => onSessionExpired?.call()),
      ErrorInterceptor(),
      if (AppConfig.enableLogging)
        InterceptorsWrapper(onError: (e, h) {
          AppTalker.instance.error('${e.requestOptions.method} ${e.requestOptions.path} -> ${e.response?.statusCode}');
          h.next(e);
        }),
    ]);
    return d;
  }

  Future<dynamic> request(String path, {HttpMethod method = HttpMethod.get, Object? data, Map<String, dynamic>? query, bool withToken = true, Options? options}) async {
    final o = (options ?? Options()).copyWith(method: method.name.toUpperCase(), extra: {'token': withToken});
    final res = await dio.request(path, data: data, queryParameters: query, options: o);
    return res.data;
  }

  Future<dynamic> uploadFile(String path, List<int> bytes, {Map<String, dynamic>? query}) =>
      request(path, method: HttpMethod.post, data: Stream.fromIterable([bytes]), query: query, options: Options(contentType: 'application/octet-stream', headers: {Headers.contentLengthHeader: bytes.length}));
}
