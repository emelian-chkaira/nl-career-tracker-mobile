import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/format.dart';
import '../../auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import '../../../global/widgets/widgets.dart';
import '../cubit/job_detail_cubit.dart';
import 'job_tile.dart';

const stages = ['shortlisted', 'applied', 'screening', 'interview', 'offer', 'accepted', 'rejected', 'withdrawn', 'skipped'];

/// Plain-text posting -> paragraphs, bullet lists and short sub-headings.
class JobDescription extends StatelessWidget {
  const JobDescription(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final out = <Widget>[];
    for (final raw in text.split(RegExp(r'\n+'))) {
      final l = raw.trim();
      if (l.isEmpty) continue;
      if (RegExp(r'^[-*•·]\s+').hasMatch(l)) {
        out.add(Padding(padding: const EdgeInsets.only(left: 4, bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('•  '), Expanded(child: Text(l.replaceFirst(RegExp(r'^[-*•·]\s+'), ''), style: t.bodyMedium?.copyWith(height: 1.45)))])));
      } else if (RegExp(r'^[^.!?]{3,60}:$').hasMatch(l) && l.split(' ').length <= 7) {
        out.add(Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Text(l.replaceFirst(RegExp(r':$'), ''), style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800))));
      } else {
        out.add(Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(l, style: t.bodyMedium?.copyWith(height: 1.45))));
      }
    }
    return SelectionArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: out));
  }
}

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.jobId});
  final int jobId;
  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobDetailCubit>().load(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AppWrapperCubit>().state.userState == UserState.authenticated;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      appBar: AppBar(title: const Text('Job')),
      body: BlocBuilder<JobDetailCubit, JobDetailState>(
        builder: (context, s) => StatusView(
          state: s,
          onRetry: () => context.read<JobDetailCubit>().load(widget.jobId),
          builder: (_) {
            final j = s.job!;
            return Column(children: [
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          CompanyLogo(j.company, size: 60),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(j.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
                            const SizedBox(height: 4),
                            Text('${j.company.name} · ${(j.location ?? 'Netherlands').split(';').first.trim()} · ${ago(j.date)}', style: TextStyle(color: muted)),
                          ])),
                        ]),
                        const SizedBox(height: 12),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          if (j.company.sponsor) const Pill('IND sponsor', color: Color(0xFF0E8A5F)),
                          Pill(label(j.jobType)),
                          if (j.language != 'unknown') Pill(label(j.language)),
                          if (j.remote) const Pill('Remote friendly'),
                        ]),
                        if (signedIn) ...[
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: j.stage,
                            decoration: const InputDecoration(labelText: 'Pipeline stage'),
                            hint: const Text('Not tracked'),
                            items: [for (final x in stages) DropdownMenuItem(value: x, child: Text(label(x)))],
                            onChanged: (v) => v == null ? null : context.read<JobDetailCubit>().setStage(v),
                          ),
                        ] else
                          TextButton(onPressed: () => Navigator.of(context).pushNamed(AppRouter.login), child: const Text('Sign in to track this job')),
                      ]),
                    ),
                  ),
                  if (j.skills.isNotEmpty) ...[const SizedBox(height: 10), Section('Skills mentioned', child: Wrap(spacing: 6, runSpacing: 6, children: [for (final e in j.skills) Pill(e)]))],
                  const SizedBox(height: 10),
                  Section('About the role', child: j.description?.isNotEmpty == true ? JobDescription(j.description!) : Text('No description captured. Open the posting on the company site.', style: TextStyle(color: muted))),
                ]),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
                  child: Row(children: [
                    Expanded(flex: 3, child: FilledButton.icon(icon: const Icon(Icons.open_in_new, size: 18), label: const Text('Apply on company site'), onPressed: () => launchUrl(Uri.parse(j.url), mode: LaunchMode.externalApplication))),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: OutlinedButton.icon(icon: const Icon(Icons.description_outlined, size: 18), label: const Text('Tailor CV'), onPressed: () => Navigator.of(context).pushNamed(AppRouter.cv, arguments: j.id))),
                  ]),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
