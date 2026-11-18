import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../models/alert_models.dart';
import '../repo/alerts_repo.dart';

class AlertsState extends FeatureState {
  final List<SavedSearchModel> searches;
  final List<NotificationModel> notifications;
  final int unread;
  const AlertsState({super.status, super.error, this.searches = const [], this.notifications = const [], this.unread = 0});
  @override
  List<Object?> get props => [...super.props, searches, notifications, unread];
}

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit({required this.repo}) : super(const AlertsState());
  final AlertsRepo repo;

  Future<void> load() async {
    emit(AlertsState(status: Status.loading, searches: state.searches, notifications: state.notifications, unread: state.unread));
    try {
      final s = await repo.searches();
      final n = await repo.notifications();
      emit(AlertsState(status: Status.loaded, searches: s, notifications: n.items, unread: n.unread));
    } on CustomDioException catch (e) {
      emit(AlertsState(status: Status.failed, error: e));
    }
  }

  Future<void> _then(Future<void> Function() op) async {
    try {
      await op();
      await load();
    } on CustomDioException catch (e) {
      emit(AlertsState(status: Status.failed, error: e, searches: state.searches, notifications: state.notifications));
    }
  }

  Future<void> save(String name, Map<String, dynamic> params, {String frequency = 'daily'}) => _then(() => repo.createSearch(name, params, frequency));
  Future<void> setFrequency(int id, String f) => _then(() => repo.setFrequency(id, f));
  Future<void> delete(int id) => _then(() => repo.deleteSearch(id));
  Future<void> markRead(int id) => _then(() => repo.markRead(id));
  Future<void> markAllRead() => _then(repo.markAllRead);
}
