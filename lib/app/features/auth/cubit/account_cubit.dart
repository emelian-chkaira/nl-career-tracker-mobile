import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../app_wrapper_cubit/app_wrapper_cubit.dart';
import '../repo/auth_repo.dart';

class AccountState extends FeatureState {
  const AccountState({super.status, super.error, this.done = false});
  final bool done;
  AccountState copyWith({Status? status, error, bool? done}) => AccountState(status: status ?? this.status, error: error, done: done ?? this.done);
}

/// Forgot / reset password and e-mail verification. The e-mail links open the web app, so on mobile the user pastes the link (or just its code).
class AccountCubit extends Cubit<AccountState> {
  AccountCubit({required this.repo, required this.wrapper}) : super(const AccountState());
  final AuthRepo repo;
  final AppWrapperCubit wrapper;

  /// Accepts the whole link ("https://…/reset?token=abc") or the bare token.
  static String tokenFrom(String input) {
    final t = input.trim();
    final m = RegExp(r'(?:token|oobCode)=([\w-]+)').firstMatch(t);
    return m != null ? m.group(1)! : t;
  }

  Future<void> _run(Future<void> Function() call) async {
    emit(state.copyWith(status: Status.loading));
    try {
      await call();
      emit(state.copyWith(status: Status.loaded, done: true));
    } on CustomDioException catch (e) {
      emit(state.copyWith(status: Status.failed, error: e));
    }
  }

  Future<void> forgot(String email) => _run(() => repo.forgot(email.trim()));
  Future<void> reset(String link, String password) => _run(() => repo.reset(tokenFrom(link), password));
  Future<void> resend() => _run(repo.resendVerification);
  Future<void> verify(String link) => _run(() async {
        final u = await repo.verify(tokenFrom(link));
        if (wrapper.state.user?.id == u.id) wrapper.userUpdated(u);
      });
}
