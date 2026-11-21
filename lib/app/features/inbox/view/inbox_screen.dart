import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/format.dart';
import '../../../global/widgets/widgets.dart';
import '../../auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import '../cubit/inbox_cubit.dart';
import '../models/inbox_models.dart';

const _cats = ['interview_invite', 'assessment', 'offer', 'rejection', 'application_received', 'recruiter_outreach'];
const _colors = {'application_received': Color(0xFF3B82F6), 'interview_invite': Color(0xFF8B5CF6), 'assessment': Color(0xFFF59E0B), 'offer': Color(0xFF10B981), 'rejection': Color(0xFFEF4444), 'recruiter_outreach': Color(0xFF06B6D4)};

/// Review queue of job e-mails found in the user's Gmail. Sync and Connect use the same API as the web app.
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<AppWrapperCubit>().state.userState == UserState.authenticated) context.read<InboxCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppWrapperCubit>().state.userState != UserState.authenticated) return const SignInPrompt(what: 'read your job e-mails');
    final c = context.read<InboxCubit>();
    return BlocBuilder<InboxCubit, InboxState>(
      builder: (context, s) => StatusView(
        state: s,
        onRetry: c.load,
        builder: (_) {
          final items = s.category.isEmpty ? s.items : s.items.where((e) => e.category == s.category).toList();
          return RefreshIndicator(
            onRefresh: c.load,
            child: ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
              _Connection(s: s),
              const SizedBox(height: 10),
              SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final k in _cats)
                  Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(selected: s.category == k, label: Text('${label(k)} ${s.categories[k] ?? 0}'), onSelected: (_) => c.filter(k), visualDensity: VisualDensity.compact)),
              ])),
              const SizedBox(height: 8),
              if (items.isEmpty) const Padding(padding: EdgeInsets.only(top: 40), child: EmptyView('It is quiet in here. Press Sync now and we will look through your Gmail.', icon: Icons.mark_email_unread_outlined)),
              for (final e in items) _EventCard(e: e),
            ]),
          );
        },
      ),
    );
  }
}

class _Connection extends StatelessWidget {
  const _Connection({required this.s});
  final InboxState s;
  @override
  Widget build(BuildContext context) {
    final c = context.read<InboxCubit>(), cs = Theme.of(context).colorScheme;
    if (s.accounts.isEmpty) {
      return Section('Connect Gmail', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Sign in on Google\'s own page and allow read-only access. No password is shared, and only extracted facts are kept, never the e-mail text.', style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: s.configured ? () async { final u = await c.connectUrl(); if (u != null) await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); } : null,
          child: const Text('Connect Gmail'),
        ),
        if (!s.configured) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Gmail sign-in is not set up on this server yet (see docs/GMAIL_OAUTH.md).', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5))),
        Padding(padding: const EdgeInsets.only(top: 8), child: Text('After you allow access, come back here and pull down to refresh.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5))),
      ]));
    }
    final a = s.accounts.first;
    return Section(a.username, trailing: TextButton(onPressed: s.syncing ? null : () => _confirm(context, c), child: const Text('Disconnect')), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(a.lastError ?? (a.lastSyncAt == null ? 'Never read yet.' : 'Last read ${ago(a.lastSyncAt)}.'), style: TextStyle(color: a.lastError != null ? cs.error : cs.onSurfaceVariant, fontSize: 13)),
      const SizedBox(height: 10),
      Row(children: [
        FilledButton(onPressed: s.syncing ? null : () => c.sync(), child: Text(s.syncing ? 'Reading…' : 'Sync now')),
        const SizedBox(width: 12),
        Expanded(child: Text(s.syncText, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5))),
      ]),
      if (s.syncing) const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator()),
    ]));
  }

  Future<void> _confirm(BuildContext context, InboxCubit c) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Disconnect Gmail?'), content: const Text('The saved Google access is deleted. E-mails already extracted stay.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Disconnect'))]));
    if (ok == true) await c.disconnect();
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.e});
  final MailEventModel e;
  @override
  Widget build(BuildContext context) {
    final c = context.read<InboxCubit>(), cs = Theme.of(context).colorScheme, color = _colors[e.category] ?? cs.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(e.company ?? 'Unknown company', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5))),
              Text(ago(e.receivedAt), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5)),
            ]),
            if (e.role != null) Text(e.role!, style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 6),
            Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(label(e.category), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5))]),
            if (e.summary != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(e.summary!)),
            if (e.jobTitle != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Linked to your pipeline job ${e.jobTitle}${e.suggestedStage == null ? '' : ' to ${label(e.suggestedStage!)}'}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5))),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => c.act(e, false), child: const Text('Dismiss')),
              const SizedBox(width: 6),
              FilledButton(onPressed: () => c.act(e, true), child: Text(e.jobTitle != null ? 'Accept & update' : 'Keep')),
            ]),
          ]),
        ),
      ),
    );
  }
}
