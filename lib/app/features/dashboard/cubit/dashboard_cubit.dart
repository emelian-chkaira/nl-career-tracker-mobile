import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../models/overview_model.dart';
import '../repo/dashboard_repo.dart';

class DashboardState extends FeatureState {
  final Overview? data;
  final int days;
  const DashboardState({super.status, super.error, this.data, this.days = 90});
  @override
  List<Object?> get props => [...super.props, data, days];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required this.repo}) : super(const DashboardState());
  final DashboardRepo repo;

  Future<void> load({int? days}) async {
    final d = days ?? state.days;
    emit(DashboardState(status: Status.loading, days: d, data: state.data));
    try {
      emit(DashboardState(status: Status.loaded, days: d, data: await repo.overview(days: d)));
    } on CustomDioException catch (e) {
      emit(DashboardState(status: Status.failed, error: e, days: d));
    }
  }
}
