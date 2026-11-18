import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../../jobs/models/job_model.dart';
import '../repo/pipeline_repo.dart';

typedef PipelineState = PaginatedState<JobModel>;

class PipelineCubit extends Cubit<PipelineState> {
  PipelineCubit({required this.repo}) : super(const PipelineState());
  final PipelineRepo repo;

  Future<void> load() async {
    emit(const PipelineState(status: Status.loading));
    try {
      final items = await repo.items();
      emit(PipelineState(status: Status.loaded, items: items, total: items.length));
    } on CustomDioException catch (e) {
      emit(PipelineState(status: Status.failed, error: e));
    }
  }

  Future<void> move(int id, String stage) async {
    try {
      await repo.setStage(id, stage);
      await load();
    } on CustomDioException catch (e) {
      emit(PipelineState(status: Status.failed, error: e, items: state.items));
    }
  }

  Future<void> remove(int id) async {
    try {
      await repo.remove(id);
      await load();
    } on CustomDioException catch (e) {
      emit(PipelineState(status: Status.failed, error: e, items: state.items));
    }
  }
}
