import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/base_states/base_states.dart';
import '../../../../core/styles/style.dart';
import '../../../../core/routes/app_router.dart';
import '../../../global/widgets/widgets.dart';
import '../../alerts/cubit/alerts_cubit.dart';
import '../../auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import '../cubit/jobs_cubit.dart';
import '../cubit/jobs_state.dart';
import '../models/job_model.dart';
import 'filters_sheet.dart';
import 'job_tile.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key, required this.title});
  final String title;
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _scroll = ScrollController();
  final _q = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) context.read<JobsCubit>().loadMore();
    });
    context.read<JobsCubit>().load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _q.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    if (context.read<AppWrapperCubit>().state.userState != UserState.authenticated) {
      Navigator.of(context).pushNamed(AppRouter.login);
      return;
    }
    final jobs = context.read<JobsCubit>();
    final alerts = context.read<AlertsCubit>();
    final name = TextEditingController(text: jobs.state.filters.q.isEmpty ? 'My search' : jobs.state.filters.q);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save search'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), const SizedBox(height: 8), const Text('You will get daily alerts for new matches.')]),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))],
      ),
    );
    if (ok == true) {
      await alerts.save(name.text.trim().isEmpty ? 'My search' : name.text.trim(), jobs.state.filters.toQuery());
      if (context.mounted) showSnack(context, 'Saved. Manage it under Alerts.');
    }
  }

  static const _quick = ['python', 'flutter', 'react', 'data engineer', 'devops', 'machine learning'];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<JobsCubit>();
    final intern = widget.title == 'Internships';
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<JobsCubit, JobsState>(
          builder: (context, s) => RefreshIndicator(
            onRefresh: cubit.refresh,
            child: CustomScrollView(controller: _scroll, physics: const AlwaysScrollableScrollPhysics(), slivers: [
              SliverToBoxAdapter(
                child: HeroBanner(
                  title: intern ? 'Find your internship in the Netherlands' : 'Tech jobs in the Netherlands',
                  subtitle: 'Read straight from employers\' own career pages. No aggregators.',
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
                          child: TextField(controller: _q, textInputAction: TextInputAction.search, onSubmitted: cubit.setQuery, decoration: InputDecoration(hintText: 'Role, skill or company', border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false, prefixIcon: const Icon(Icons.search), suffixIcon: _q.text.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { _q.clear(); cubit.setQuery(''); setState(() {}); })), onChanged: (_) => setState(() {})),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Badge(
                        isLabelVisible: s.filters.activeCount > 0,
                        label: Text('${s.filters.activeCount}'),
                        child: IconButton.filled(style: IconButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white), icon: const Icon(Icons.tune), onPressed: () => showFiltersSheet(context, cubit)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      child: ListView(scrollDirection: Axis.horizontal, children: [
                        for (final q in _quick)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () { _q.text = q; cubit.setQuery(q); setState(() {}); },
                              child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0x33FFFFFF), border: Border.all(color: const Color(0x55FFFFFF)), borderRadius: BorderRadius.circular(99)), child: Text(q, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600))),
                            ),
                          ),
                      ]),
                    ),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  child: Row(children: [
                    Expanded(child: Text(s.status == Status.loaded ? '${s.total} results' : '', style: const TextStyle(fontWeight: FontWeight.w700))),
                    TextButton.icon(onPressed: () => _save(context), icon: const Icon(Icons.notifications_active_outlined, size: 18), label: const Text('Alert me')),
                  ]),
                ),
              ),
              if (s.status == Status.loading && s.items.isEmpty) const SliverToBoxAdapter(child: Loading())
              else if (s.status == Status.failed && s.items.isEmpty) SliverToBoxAdapter(child: TryAgain(error: s.error, onRetry: cubit.refresh))
              else if (s.items.isEmpty) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(top: 60), child: EmptyView('No jobs match. Loosen the filters or try another search.', icon: Icons.search_off)))
              else SliverList.builder(
                itemCount: s.items.length + 1,
                itemBuilder: (context, i) {
                  if (i == s.items.length) return s.hasReachedMax ? const SizedBox(height: 28) : const Loading();
                  final JobModel j = s.items[i];
                  return JobTile(job: j, onTap: () => Navigator.of(context).pushNamed(AppRouter.jobDetail, arguments: j.id));
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
