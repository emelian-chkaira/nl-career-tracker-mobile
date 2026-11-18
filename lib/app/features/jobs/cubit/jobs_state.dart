import '../../../../core/base_states/base_states.dart';
import '../models/job_model.dart';

class JobsState extends PaginatedState<JobModel> {
  final JobFilters filters;
  final Map<String, List<Facet>> facets;
  final int page;
  const JobsState({super.status, super.error, super.items, super.hasReachedMax, super.total, this.filters = const JobFilters(), this.facets = const {}, this.page = 1});

  JobsState copyWithJobs({Status? status, error, List<JobModel>? items, bool? hasReachedMax, int? total, JobFilters? filters, Map<String, List<Facet>>? facets, int? page}) => JobsState(
      status: status ?? this.status, error: error, items: items ?? this.items, hasReachedMax: hasReachedMax ?? this.hasReachedMax, total: total ?? this.total, filters: filters ?? this.filters, facets: facets ?? this.facets, page: page ?? this.page);

  @override
  List<Object?> get props => [...super.props, filters, facets, page];
}
