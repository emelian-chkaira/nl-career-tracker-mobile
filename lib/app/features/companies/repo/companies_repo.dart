import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/api/errors/executer.dart';
import '../../jobs/models/job_model.dart';

class CompaniesRepo {
  final _api = ApiClient();
  Future<({List<CompanyModel> items, int total})> list({String q = '', int page = 1, bool hiring = true}) => Executer.execute(() async {
        final r = await _api.request(Endpoints.companies, query: {'q': q, 'page': page, 'hiring': hiring, 'limit': 30});
        return (items: (r['items'] as List).map((e) => CompanyModel.fromJson(e)).toList(), total: r['total'] as int);
      }, name: 'companies');
}
