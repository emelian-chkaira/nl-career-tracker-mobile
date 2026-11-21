import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../models/inbox_models.dart';
import '../repo/inbox_repo.dart';

class InboxState extends FeatureState {
  const InboxState({super.status, super.error, this.items = const [], this.categories = const {}, this.counts = const {}, this.accounts = const [], this.configured = false, this.syncing = false, this.syncText = '', this.category = ''});
  final List<MailEventModel> items;
  final Map<String, int> categories, counts;
  final List<MailAccountModel> accounts;
  final bool configured, syncing;
  final String syncText, category;
  @override
  List<Object?> get props => [...super.props, items, categories, counts, accounts, configured, syncing, syncText, category];
  InboxState copyWith({Status? status, CustomDioException? error, List<MailEventModel>? items, Map<String, int>? categories, Map<String, int>? counts, List<MailAccountModel>? accounts, bool? configured, bool? syncing, String? syncText, String? category}) =>
      InboxState(status: status ?? this.status, error: error, items: items ?? this.items, categories: categories ?? this.categories, counts: counts ?? this.counts, accounts: accounts ?? this.accounts, configured: configured ?? this.configured, syncing: syncing ?? this.syncing, syncText: syncText ?? this.syncText, category: category ?? this.category);
}

class InboxCubit extends Cubit<InboxState> {
  InboxCubit({required this.repo}) : super(const InboxState());
  final InboxRepo repo;

  Future<void> load() async {
    emit(state.copyWith(status: state.items.isEmpty ? Status.loading : state.status));
    try {
      final e = await repo.events('new');
      final a = await repo.accounts();
      final c = a.isEmpty ? await repo.gmailConfigured() : true;
      emit(state.copyWith(status: Status.loaded, items: e.items, categories: e.categories, counts: e.status, accounts: a, configured: c));
    } on CustomDioException catch (e) {
      emit(state.copyWith(status: Status.failed, error: e));
    }
  }

  void filter(String c) => emit(state.copyWith(category: state.category == c ? '' : c));

  Future<String?> connectUrl() async {
    try { return await repo.gmailUrl(); } on CustomDioException catch (e) { emit(state.copyWith(error: e)); return null; }
  }

  Future<void> sync({int days = 60}) async {
    if (state.accounts.isEmpty || state.syncing) return;
    emit(state.copyWith(syncing: true, syncText: 'Reading your Gmail…'));
    try {
      final id = await repo.sync(state.accounts.first.id, days);
      for (var i = 0; i < 1200; i++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final t = await repo.syncStatus(id), p = (t['progress'] as Map?) ?? {};
        if (t['status'] == 'failed') { emit(state.copyWith(syncing: false, syncText: 'Sync failed: ${t['error'] ?? 'unknown error'}')); return; }
        if (t['status'] == 'done') { emit(state.copyWith(syncing: false, syncText: 'Read ${p['scanned'] ?? 0} e-mails, ${p['found'] ?? 0} new job e-mails.')); break; }
        emit(state.copyWith(syncText: p['phase'] == 'analysing' ? 'Analysing ${p['scanned'] ?? 0} / ${p['total'] ?? 0}…' : 'Reading your Gmail…'));
      }
      await load();
    } on CustomDioException catch (e) {
      emit(state.copyWith(syncing: false, syncText: e.message));
    }
  }

  Future<void> act(MailEventModel e, bool accept) async {
    emit(state.copyWith(items: state.items.where((x) => x.id != e.id).toList()));
    try { await repo.act(e.id, accept); } on CustomDioException { await load(); }
  }

  Future<void> disconnect() async {
    if (state.accounts.isEmpty) return;
    await repo.disconnect(state.accounts.first.id);
    await load();
  }
}
