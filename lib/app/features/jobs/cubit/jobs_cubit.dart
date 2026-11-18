import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../models/job_model.dart';
import '../repo/jobs_repo.dart';
import 'jobs_state.dart';

/// Search + infinite scroll. One instance per screen (Jobs tab, Internships tab).
class JobsCubit extends Cubit<JobsState> {
  JobsCubit({required this.repo, JobFilters initial = const JobFilters()}) : super(JobsState(filters: initial));
  final JobsRepo repo;
  int _token = 0; // drop stale responses when the user types quickly

  Future<void> load([JobFilters? filters]) async {
    final f = filters ?? state.filters;
    final t = ++_token;
    emit(state.copyWithJobs(status: Status.loading, filters: f, items: const [], page: 1));
    try {
      final r = await repo.search(f);
      if (t != _token) return;
      emit(state.copyWithJobs(status: Status.loaded, items: r.items, total: r.total, facets: r.facets, page: 1, hasReachedMax: r.items.length >= r.total));
    } on CustomDioException catch (e) {
      if (t == _token) emit(state.copyWithJobs(status: Status.failed, error: e));
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.status != Status.loaded) return;
    final t = _token;
    try {
      final r = await repo.search(state.filters, page: state.page + 1);
      if (t != _token) return;
      final all = [...state.items, ...r.items];
      emit(state.copyWithJobs(items: all, page: state.page + 1, hasReachedMax: r.items.isEmpty || all.length >= r.total, status: Status.loaded));
    } on CustomDioException {
      // keep what we have; the user can scroll again to retry
    }
  }

  Future<void> refresh() => load();
  void setQuery(String q) => load(state.filters.copyWith(q: q));
  void apply(JobFilters f) => load(f);
}
