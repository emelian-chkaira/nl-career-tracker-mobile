import 'package:dio/dio.dart';

import '../../logging/app_talker.dart';
import 'custom_errors.dart';

/// Wraps repo calls so every failure surfaces to the cubit as a CustomDioException.
class Executer {
  static Future<T> execute<T>(Future<T> Function() operation, {String? name}) async {
    try {
      return await operation();
    } on CustomDioException catch (e) {
      AppTalker.instance.warning('${name ?? 'operation'} failed: $e');
      rethrow;
    } on DioException catch (e) {
      throw CustomDioException.fromDioError(e);
    } catch (e, st) {
      AppTalker.instance.handle(e, st, '${name ?? 'operation'} unexpected');
      throw CustomDioException(RequestOptions(path: ''), null, ErrorType.unknown, 'Unexpected error');
    }
  }
}
