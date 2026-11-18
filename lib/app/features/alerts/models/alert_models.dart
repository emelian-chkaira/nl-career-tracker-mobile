import 'package:equatable/equatable.dart';

class SavedSearchModel extends Equatable {
  final int id;
  final String name, alertFrequency;
  final Map<String, dynamic> params;
  final String? lastRunAt;
  const SavedSearchModel({required this.id, required this.name, required this.alertFrequency, required this.params, this.lastRunAt});
  factory SavedSearchModel.fromJson(Map<String, dynamic> j) => SavedSearchModel(id: j['id'], name: j['name'], alertFrequency: j['alert_frequency'], params: Map<String, dynamic>.from(j['params'] ?? {}), lastRunAt: j['last_run_at']);
  @override
  List<Object?> get props => [id, name, alertFrequency, lastRunAt];
}

class NotificationModel extends Equatable {
  final int id;
  final String title, body, createdAt;
  final bool read;
  const NotificationModel({required this.id, required this.title, required this.body, required this.createdAt, required this.read});
  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(id: j['id'], title: j['title'], body: j['body'] ?? '', createdAt: j['created_at'], read: j['read'] ?? false);
  @override
  List<Object?> get props => [id, read];
}
