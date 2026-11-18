import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static SecureStorage? _instance;
  factory SecureStorage() => _instance ??= SecureStorage._(const FlutterSecureStorage());
  SecureStorage._(this._s);
  final FlutterSecureStorage _s;

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _s.write(key: _access, value: access);
    await _s.write(key: _refresh, value: refresh);
  }

  Future<String?> getAccessToken() => _s.read(key: _access);
  Future<String?> getRefreshToken() => _s.read(key: _refresh);
  Future<bool> hasSession() async => (await _s.read(key: _refresh)) != null;
  Future<void> clear() async {
    await _s.delete(key: _access);
    await _s.delete(key: _refresh);
  }
}
