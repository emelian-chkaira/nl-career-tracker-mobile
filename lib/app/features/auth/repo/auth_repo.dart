import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/api/errors/executer.dart';
import '../models/user_model.dart';

class AuthRepo {
  final _api = ApiClient();

  Future<AuthResponse> login(String email, String password) => Executer.execute(
      () async => AuthResponse.fromJson(await _api.request(Endpoints.login, method: HttpMethod.post, data: {'email': email, 'password': password}, withToken: false)),
      name: 'login');

  Future<AuthResponse> register(String email, String password, String name) => Executer.execute(
      () async => AuthResponse.fromJson(await _api.request(Endpoints.register, method: HttpMethod.post, data: {'email': email, 'password': password, 'name': name}, withToken: false)),
      name: 'register');

  Future<UserModel> me() => Executer.execute(() async => UserModel.fromJson(await _api.request(Endpoints.me)), name: 'me');

  Future<UserModel> saveProfile(Map<String, dynamic> profile) =>
      Executer.execute(() async => UserModel.fromJson(await _api.request(Endpoints.profile, method: HttpMethod.put, data: profile)), name: 'saveProfile');

  Future<void> logout(String? refreshToken) => Executer.execute(() async {
        await _api.request(Endpoints.logout, method: HttpMethod.post, data: {'refresh_token': refreshToken}, withToken: false);
      }, name: 'logout');

  Future<void> changePassword(String current, String next) =>
      Executer.execute(() async => _api.request(Endpoints.password, method: HttpMethod.post, data: {'current_password': current, 'new_password': next}), name: 'changePassword');

  Future<void> forgot(String email) =>
      Executer.execute(() async => _api.request(Endpoints.forgot, method: HttpMethod.post, data: {'email': email}, withToken: false), name: 'forgot');

  Future<void> reset(String token, String password) =>
      Executer.execute(() async => _api.request(Endpoints.reset, method: HttpMethod.post, data: {'token': token, 'new_password': password}, withToken: false), name: 'reset');

  Future<UserModel> verify(String token) =>
      Executer.execute(() async => UserModel.fromJson(await _api.request(Endpoints.verify, method: HttpMethod.post, data: {'token': token}, withToken: false)), name: 'verify');

  Future<void> resendVerification() => Executer.execute(() async => _api.request(Endpoints.verifySend, method: HttpMethod.post), name: 'resendVerification');

  /// Server's Google web client ID, or null when Google sign-in is not configured.
  Future<String?> googleClientId() => Executer.execute(() async => (await _api.request(Endpoints.authConfig, withToken: false))['google_client_id'] as String?, name: 'authConfig');

  Future<AuthResponse> google(String idToken) => Executer.execute(
      () async => AuthResponse.fromJson(await _api.request(Endpoints.google, method: HttpMethod.post, data: {'credential': idToken}, withToken: false)),
      name: 'google');
}
