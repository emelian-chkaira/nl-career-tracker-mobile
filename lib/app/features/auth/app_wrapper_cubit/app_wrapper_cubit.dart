import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/database/secure/secure_storage.dart';
import '../models/user_model.dart';
import '../repo/auth_repo.dart';

enum UserState { unknown, guest, authenticated }

class AppWrapperState extends Equatable {
  final UserState userState;
  final UserModel? user;
  const AppWrapperState({this.userState = UserState.unknown, this.user});
  @override
  List<Object?> get props => [userState, user];
}

/// Global session state: decides guest vs signed-in, restores the session on start, signs out.
class AppWrapperCubit extends Cubit<AppWrapperState> {
  AppWrapperCubit({required this.repo, required this.secureStorage}) : super(const AppWrapperState()) {
    ApiClient().onSessionExpired = () {
      if (!isClosed) emit(const AppWrapperState(userState: UserState.guest));
    };
  }
  final AuthRepo repo;
  final SecureStorage secureStorage;

  Future<void> appStarted() async {
    if (!await secureStorage.hasSession()) return emit(const AppWrapperState(userState: UserState.guest));
    try {
      emit(AppWrapperState(userState: UserState.authenticated, user: await repo.me()));
    } on CustomDioException catch (e) {
      if (e.errorType == ErrorType.noInternet) return emit(const AppWrapperState(userState: UserState.guest)); // keep tokens for next start
      await secureStorage.clear();
      emit(const AppWrapperState(userState: UserState.guest));
    }
  }

  void signedIn(UserModel u) => emit(AppWrapperState(userState: UserState.authenticated, user: u));
  void userUpdated(UserModel u) => emit(AppWrapperState(userState: UserState.authenticated, user: u));

  Future<void> signOut() async {
    final rt = await secureStorage.getRefreshToken();
    try {
      await repo.logout(rt);
    } catch (_) {/* best effort */}
    await secureStorage.clear();
    emit(const AppWrapperState(userState: UserState.guest));
  }
}
