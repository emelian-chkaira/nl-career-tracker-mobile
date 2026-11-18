import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/api/errors/executer.dart';
import '../models/job_model.dart';

class JobsRepo {
  final _api = ApiClient();

  Future<JobSearchResult> search(JobFilters f, {int page = 1, int limit = 20}) => Executer.execute(
      () async => JobSearchResult.fromJson(await _api.request(Endpoints.jobs, query: {...f.toQuery(), 'page': page, 'limit': limit})),
      name: 'searchJobs');

  Future<JobModel> detail(int id) => Executer.execute(() async => JobModel.fromJson(await _api.request(Endpoints.job(id))), name: 'jobDetail');

  Future<void> setStage(int id, String stage) => Executer.execute(() async => _api.request(Endpoints.myJob(id), method: HttpMethod.put, data: {'stage': stage}), name: 'setStage');
}
