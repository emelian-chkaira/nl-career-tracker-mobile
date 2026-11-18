import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../../auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import '../../auth/repo/auth_repo.dart';

class ProfileState extends FeatureState {
  final String? message;
  const ProfileState({super.status, super.error, this.message});
  @override
  List<Object?> get props => [...super.props, message];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.repo, required this.wrapper}) : super(const ProfileState());
  final AuthRepo repo;
  final AppWrapperCubit wrapper;

  Future<void> save({required List<String> skills, required List<String> titles, required List<String> cities, required bool englishOnly}) async {
    emit(const ProfileState(status: Status.loading));
    try {
      final base = Map<String, dynamic>.from(wrapper.state.user?.profile ?? {});
      final u = await repo.saveProfile({...base, 'skills': skills, 'titles': titles, 'cities': cities, 'english_only': englishOnly});
      wrapper.userUpdated(u);
      emit(const ProfileState(status: Status.loaded, message: 'Profile saved'));
    } on CustomDioException catch (e) {
      emit(ProfileState(status: Status.failed, error: e));
    }
  }
}
