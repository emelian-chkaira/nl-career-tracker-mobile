import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_config.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../../../../core/database/secure/secure_storage.dart';
import '../app_wrapper_cubit/app_wrapper_cubit.dart';
import '../models/user_model.dart';
import '../repo/auth_repo.dart';
import 'auth_state.dart';

/// Login / register forms. On success hands the user to the AppWrapperCubit (the single source of "who is signed in").
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.repo, required this.secureStorage, required this.wrapper}) : super(const AuthState());
  final AuthRepo repo;
  final SecureStorage secureStorage;
  final AppWrapperCubit wrapper;

  Future<void> login(String email, String password) => _run(() => repo.login(email.trim(), password));
  Future<void> register(String email, String password, String name) => _run(() => repo.register(email.trim(), password, name.trim()));

  /// Server's Google web client ID (null = feature off). Cached so the button decides once.
  Future<String?> googleClientId() async {
    try { return await repo.googleClientId(); } on CustomDioException { return null; }
  }

  /// Native Google account picker -> ID token -> our API. Cancelling the picker is not an error.
  Future<void> google(String serverClientId) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final gs = GoogleSignIn(scopes: const ['email'], serverClientId: serverClientId, clientId: AppConfig.googleIosClientId.isEmpty ? null : AppConfig.googleIosClientId);
      final acct = await gs.signIn();
      if (acct == null) { emit(state.copyWith(status: Status.initial)); return; }
      final token = (await acct.authentication).idToken;
      if (token == null) throw Exception('no token');
      await _run(() => repo.google(token));
    } on CustomDioException catch (e) {
      emit(state.copyWith(status: Status.failed, error: e));
    } catch (_) {
      emit(state.copyWith(status: Status.failed, error: CustomDioException(RequestOptions(), null, ErrorType.unknown, 'Google sign-in failed')));
    }
  }

  Future<void> _run(Future<AuthResponse> Function() call) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final r = await call();
      await secureStorage.saveTokens(access: r.accessToken, refresh: r.refreshToken);
      wrapper.signedIn(r.user);
      emit(state.copyWith(status: Status.loaded));
    } on CustomDioException catch (e) {
      emit(state.copyWith(status: Status.failed, error: e));
    }
  }
}
