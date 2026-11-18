import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../../jobs/models/job_model.dart';
import '../repo/companies_repo.dart';

typedef CompaniesState = PaginatedState<CompanyModel>;

class CompaniesCubit extends Cubit<CompaniesState> {
  CompaniesCubit({required this.repo}) : super(const CompaniesState());
  final CompaniesRepo repo;
  String _q = '';
  int _page = 1;
  int _token = 0;

  Future<void> load([String? q]) async {
    _q = q ?? _q;
    _page = 1;
    final t = ++_token;
    emit(const CompaniesState(status: Status.loading));
    try {
      final r = await repo.list(q: _q);
      if (t == _token) emit(CompaniesState(status: Status.loaded, items: r.items, total: r.total, hasReachedMax: r.items.length >= r.total));
    } on CustomDioException catch (e) {
      if (t == _token) emit(CompaniesState(status: Status.failed, error: e));
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.status != Status.loaded) return;
    try {
      final r = await repo.list(q: _q, page: _page + 1);
      _page++;
      final all = [...state.items, ...r.items];
      emit(state.copyWith(items: all, hasReachedMax: r.items.isEmpty || all.length >= r.total));
    } on CustomDioException {/* retry on next scroll */}
  }
}
