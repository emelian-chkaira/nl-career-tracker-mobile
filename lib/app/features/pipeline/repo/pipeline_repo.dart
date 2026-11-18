import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/api/errors/executer.dart';
import '../../jobs/models/job_model.dart';

class PipelineRepo {
  Future<List<JobModel>> items() => Executer.execute(() async => ((await ApiClient().request(Endpoints.pipeline))['items'] as List).map((e) => JobModel.fromJson(e)).toList(), name: 'pipeline');
  Future<void> setStage(int id, String stage) => Executer.execute(() async => ApiClient().request(Endpoints.myJob(id), method: HttpMethod.put, data: {'stage': stage}), name: 'setStage');
  Future<void> remove(int id) => Executer.execute(() async => ApiClient().request(Endpoints.myJob(id), method: HttpMethod.delete), name: 'removeFromPipeline');
}
