import '../../../../core/api/api_client.dart';
import '../../../../core/api/errors/executer.dart';
import '../models/inbox_models.dart';

class InboxRepo {
  final _api = ApiClient();

  Future<({List<MailEventModel> items, Map<String, int> categories, Map<String, int> status})> events(String status) => Executer.execute(() async {
        final r = await _api.request('/mail/events', query: {'status': status});
        Map<String, int> m(Object? o) => ((o as Map?) ?? {}).map((k, v) => MapEntry(k as String, (v as num).toInt()));
        return (items: (r['items'] as List).map((e) => MailEventModel.fromJson(e)).toList(), categories: m(r['counts']['category']), status: m(r['counts']['status']));
      }, name: 'mailEvents');

  Future<List<MailAccountModel>> accounts() => Executer.execute(() async => ((await _api.request('/mail/accounts')) as List).map((e) => MailAccountModel.fromJson(e)).toList(), name: 'mailAccounts');
  Future<bool> gmailConfigured() => Executer.execute(() async => (await _api.request('/mail/gmail/status'))['configured'] == true, name: 'gmailStatus');
  Future<String> gmailUrl() => Executer.execute(() async => (await _api.request('/mail/gmail/start', method: HttpMethod.post, data: {}))['url'] as String, name: 'gmailStart');
  Future<int> sync(int accountId, int days) => Executer.execute(() async => (await _api.request('/mail/sync', method: HttpMethod.post, data: {'account_id': accountId, 'days': days}))['task_id'] as int, name: 'mailSync');
  Future<Map<String, dynamic>> syncStatus(int id) => Executer.execute(() async => Map<String, dynamic>.from(await _api.request('/mail/sync/$id')), name: 'mailSyncStatus');
  Future<void> act(int id, bool accept) => Executer.execute(() async => _api.request('/mail/events/$id/${accept ? 'accept' : 'dismiss'}', method: HttpMethod.post), name: 'mailAct');
  Future<void> disconnect(int id) => Executer.execute(() async => _api.request('/mail/accounts/$id', method: HttpMethod.delete), name: 'mailDisconnect');
}
