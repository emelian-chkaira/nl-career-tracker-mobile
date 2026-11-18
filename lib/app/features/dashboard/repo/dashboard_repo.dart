import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/api/errors/executer.dart';
import '../models/overview_model.dart';

class DashboardRepo {
  Future<Overview> overview({int days = 90, String? kind}) => Executer.execute(
      () async => Overview.fromJson(await ApiClient().request(Endpoints.analytics, query: {'days': days, if (kind != null) 'kind': kind}, withToken: false)),
      name: 'overview');
}
