import 'package:flutter/material.dart';

import '../../../../core/utils/format.dart';
import '../cubit/jobs_cubit.dart';
import '../models/job_model.dart';

Future<void> showFiltersSheet(BuildContext context, JobsCubit cubit) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FiltersSheet(initial: cubit.state.filters, facets: cubit.state.facets, onApply: cubit.apply),
    );

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.initial, required this.facets, required this.onApply});
  final JobFilters initial;
  final Map<String, List<Facet>> facets;
  final ValueChanged<JobFilters> onApply;
  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late JobFilters f = widget.initial;

  List<String> _toggle(List<String> l, String v) => l.contains(v) ? l.where((x) => x != v).toList() : [...l, v];

  Widget _group(String title, String key, List<String> selected, JobFilters Function(List<String>) update, {bool pretty = false}) {
    final facets = widget.facets[key] ?? const [];
    if (facets.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        Wrap(spacing: 6, children: [
          for (final x in facets.take(10)) FilterChip(label: Text('${pretty ? label(x.value) : x.value} (${x.count})'), selected: selected.contains(x.value), onSelected: (_) => setState(() => f = update(_toggle(selected, x.value)))),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .85),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), shrinkWrap: true, children: [
            Row(children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton(onPressed: () => setState(() => f = JobFilters(q: f.q, kind: f.kind)), child: const Text('Reset')),
            ]),
            const Text('Search mode'),
            const SizedBox(height: 6),
            SegmentedButton<String>(segments: const [ButtonSegment(value: 'hybrid', label: Text('Hybrid')), ButtonSegment(value: 'keyword', label: Text('Keyword')), ButtonSegment(value: 'semantic', label: Text('Semantic'))], selected: {f.mode}, onSelectionChanged: (s) => setState(() => f = f.copyWith(mode: s.first))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey('sort-${f.sort}'),
              initialValue: f.sort,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: const [DropdownMenuItem(value: null, child: Text('Best match')), DropdownMenuItem(value: 'newest', child: Text('Newest')), DropdownMenuItem(value: 'salary', child: Text('Salary')), DropdownMenuItem(value: 'fit', child: Text('My fit (signed in)'))],
              onChanged: (v) => setState(() => f = f.copyWith(sort: v)),
            ),
            const SizedBox(height: 12),
            _group('Type', 'job_type', f.jobType, (l) => f.copyWith(jobType: l), pretty: true),
            _group('City', 'city', f.city, (l) => f.copyWith(city: l)),
            _group('Language', 'language', f.language, (l) => f.copyWith(language: l), pretty: true),
            _group('Skills', 'skills', f.skills, (l) => f.copyWith(skills: l)),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Remote friendly'), value: f.remote == true, onChanged: (v) => setState(() => f = f.copyWith(remote: v ? true : null))),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Recognised IND sponsors only'), value: f.sponsor == true, onChanged: (v) => setState(() => f = f.copyWith(sponsor: v ? true : null))),
            DropdownButtonFormField<int?>(
              key: ValueKey('days-${f.days}'),
              initialValue: f.days,
              decoration: const InputDecoration(labelText: 'Posted'),
              items: const [DropdownMenuItem(value: null, child: Text('Any time')), DropdownMenuItem(value: 1, child: Text('Last 24 hours')), DropdownMenuItem(value: 7, child: Text('Last 7 days')), DropdownMenuItem(value: 30, child: Text('Last 30 days'))],
              onChanged: (v) => setState(() => f = f.copyWith(days: v)),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () { widget.onApply(f); Navigator.pop(context); }, child: const Text('Show results')),
          ]),
        ),
      );
}
