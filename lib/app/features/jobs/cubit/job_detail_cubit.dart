import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../models/job_model.dart';
import '../repo/jobs_repo.dart';

class JobDetailState extends FeatureState {
  final JobModel? job;
  const JobDetailState({super.status, super.error, this.job});
  @override
  List<Object?> get props => [...super.props, job];
}

class JobDetailCubit extends Cubit<JobDetailState> {
  JobDetailCubit({required this.repo}) : super(const JobDetailState());
  final JobsRepo repo;

  Future<void> load(int id) async {
    emit(const JobDetailState(status: Status.loading));
    try {
      emit(JobDetailState(status: Status.loaded, job: await repo.detail(id)));
    } on CustomDioException catch (e) {
      emit(JobDetailState(status: Status.failed, error: e));
    }
  }

  Future<void> setStage(String stage) async {
    final j = state.job;
    if (j == null) return;
    try {
      await repo.setStage(j.id, stage);
      await load(j.id);
    } on CustomDioException catch (e) {
      emit(JobDetailState(status: Status.failed, error: e, job: j));
    }
  }
}
