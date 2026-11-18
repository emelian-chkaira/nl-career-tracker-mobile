import 'package:dio/dio.dart';

import '../../database/secure/secure_storage.dart';
import '../endpoints.dart';

/// On 401: rotate the refresh token once (shared by concurrent requests) and replay the request.
/// If refresh fails, tokens are cleared and [onSessionExpired] fires so the app returns to guest mode.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor(this._dio, {this.onSessionExpired});
  final Dio _dio;
  final void Function()? onSessionExpired;
  Future<bool>? _inFlight;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final skip = req.extra['token'] == false || req.extra['retried'] == true || req.path.startsWith('/auth/');
    if (err.response?.statusCode != 401 || skip) return handler.next(err);
    final ok = await (_inFlight ??= _refresh().whenComplete(() => _inFlight = null));
    if (!ok) return handler.next(err);
    try {
      req.extra['retried'] = true;
      req.headers['Authorization'] = 'Bearer ${await SecureStorage().getAccessToken()}';
      handler.resolve(await _dio.fetch(req));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refresh() async {
    final storage = SecureStorage();
    final rt = await storage.getRefreshToken();
    if (rt == null) return false;
    try {
      final r = await Dio(BaseOptions(baseUrl: Endpoints.base)).post(Endpoints.refresh, data: {'refresh_token': rt});
      await storage.saveTokens(access: r.data['access_token'], refresh: r.data['refresh_token']);
      return true;
    } catch (_) {
      await storage.clear();
      onSessionExpired?.call();
      return false;
    }
  }
}
