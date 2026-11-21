import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/format.dart';
import '../../auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import '../../../global/widgets/widgets.dart';
import '../cubit/alerts_cubit.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AppWrapperCubit>().state.userState == UserState.authenticated;
    return Scaffold(appBar: embedded ? null : AppBar(title: const Text('Alerts')), body: signedIn ? const _Body() : const SignInPrompt(what: 'save searches and get alerts'));
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  void initState() {
    super.initState();
    context.read<AlertsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.read<AlertsCubit>();
    return BlocBuilder<AlertsCubit, AlertsState>(
      builder: (context, s) => StatusView(
        state: s,
        onRetry: c.load,
        builder: (_) => RefreshIndicator(
          onRefresh: c.load,
          child: ListView(padding: const EdgeInsets.all(12), children: [
            Text('Saved searches', style: Theme.of(context).textTheme.titleMedium),
            if (s.searches.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('Nothing saved yet. Use the bookmark button on the Jobs tab.')),
            for (final x in s.searches)
              Card(
                child: ListTile(
                  title: Text(x.name),
                  subtitle: Text('${x.params['q'] ?? 'all jobs'} · checked ${ago(x.lastRunAt).isEmpty ? 'never' : ago(x.lastRunAt)}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    DropdownButton<String>(value: x.alertFrequency, underline: const SizedBox(), items: const [DropdownMenuItem(value: 'off', child: Text('Off')), DropdownMenuItem(value: 'instant', child: Text('Instant')), DropdownMenuItem(value: 'daily', child: Text('Daily')), DropdownMenuItem(value: 'weekly', child: Text('Weekly'))], onChanged: (v) => v == null ? null : c.setFrequency(x.id, v)),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => c.delete(x.id)),
                  ]),
                ),
              ),
            const SizedBox(height: 16),
            Row(children: [Text('Notifications', style: Theme.of(context).textTheme.titleMedium), const Spacer(), if (s.unread > 0) TextButton(onPressed: c.markAllRead, child: const Text('Mark all read'))]),
            if (s.notifications.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('No notifications yet.')),
            for (final n in s.notifications)
              ListTile(
                leading: Icon(n.read ? Icons.notifications_none : Icons.notifications_active, color: n.read ? null : Theme.of(context).colorScheme.primary),
                title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.w600)),
                subtitle: Text('${n.body}\n${ago(n.createdAt)}'),
                isThreeLine: true,
                onTap: n.read ? null : () => c.markRead(n.id),
              ),
          ]),
        ),
      ),
    );
  }
}
