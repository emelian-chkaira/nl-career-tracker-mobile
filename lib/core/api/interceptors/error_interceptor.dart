import 'package:dio/dio.dart';

import '../errors/custom_errors.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) => handler.next(err is CustomDioException ? err : CustomDioException.fromDioError(err));
}
