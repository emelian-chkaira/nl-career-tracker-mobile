import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/api/errors/executer.dart';
import '../models/alert_models.dart';

class AlertsRepo {
  final _api = ApiClient();

  Future<List<SavedSearchModel>> searches() => Executer.execute(() async => ((await _api.request(Endpoints.searches)) as List).map((e) => SavedSearchModel.fromJson(e)).toList(), name: 'searches');
  Future<void> createSearch(String name, Map<String, dynamic> params, String freq) =>
      Executer.execute(() async => _api.request(Endpoints.searches, method: HttpMethod.post, data: {'name': name, 'params': params, 'alert_frequency': freq}), name: 'createSearch');
  Future<void> setFrequency(int id, String freq) => Executer.execute(() async => _api.request(Endpoints.search(id), method: HttpMethod.patch, data: {'alert_frequency': freq}), name: 'setFrequency');
  Future<void> deleteSearch(int id) => Executer.execute(() async => _api.request(Endpoints.search(id), method: HttpMethod.delete), name: 'deleteSearch');

  Future<({int unread, List<NotificationModel> items})> notifications() => Executer.execute(() async {
        final r = await _api.request(Endpoints.notifications);
        return (unread: r['unread'] as int, items: (r['items'] as List).map((e) => NotificationModel.fromJson(e)).toList());
      }, name: 'notifications');
  Future<void> markRead(int id) => Executer.execute(() async => _api.request(Endpoints.notificationRead(id), method: HttpMethod.post), name: 'markRead');
  Future<void> markAllRead() => Executer.execute(() async => _api.request(Endpoints.notificationsReadAll, method: HttpMethod.post), name: 'markAllRead');
}
