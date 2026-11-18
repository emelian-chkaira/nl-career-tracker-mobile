import '../../../../core/base_states/base_states.dart';

class AuthState extends FeatureState {
  const AuthState({super.status, super.error});
  AuthState copyWith({Status? status, error}) => AuthState(status: status ?? this.status, error: error);
}
