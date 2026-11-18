import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/base_states/base_states.dart';
import '../../../global/widgets/widgets.dart';
import '../cubit/dashboard_cubit.dart';
import '../models/overview_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.read<DashboardCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Market'), actions: [
        BlocBuilder<DashboardCubit, DashboardState>(builder: (_, s) => PopupMenuButton<int>(initialValue: s.days, icon: const Icon(Icons.date_range), onSelected: (d) => c.load(days: d), itemBuilder: (_) => const [PopupMenuItem(value: 30, child: Text('30 days')), PopupMenuItem(value: 90, child: Text('90 days')), PopupMenuItem(value: 180, child: Text('180 days'))])),
      ]),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, s) => s.data != null && s.status == Status.loading
            ? const Loading()
            : StatusView(state: s, onRetry: c.load, builder: (_) => RefreshIndicator(onRefresh: c.load, child: _Content(s.data!))),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.d);
  final Overview d;
  @override
  Widget build(BuildContext context) {
    final k = d.kpi;
    final wow = (k['prev_7d'] ?? 0) > 0 ? (((k['new_7d']! - k['prev_7d']!) / k['prev_7d']!) * 100).round() : null;
    return ListView(padding: const EdgeInsets.all(12), children: [
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 1.75, mainAxisSpacing: 8, crossAxisSpacing: 8, children: [
        _Kpi('Open roles', '${k['open_jobs']?.toInt() ?? 0}'),
        _Kpi('Hiring companies', '${k['hiring_companies']?.toInt() ?? 0}'),
        _Kpi('New this week', '${k['new_7d']?.toInt() ?? 0}', sub: wow == null ? null : '${wow >= 0 ? '▲' : '▼'} ${wow.abs()}% vs last week'),
        _Kpi('Internships', '${k['internships']?.toInt() ?? 0}'),
        _Kpi('Remote friendly', '${k['remote_jobs']?.toInt() ?? 0}'),
        _Kpi('At IND sponsors', '${k['sponsor_jobs']?.toInt() ?? 0}'),
      ]),
      const SizedBox(height: 12),
      _Card('New postings per day (peak ${d.daily.fold<int>(0, (m, e) => e.n > m ? e.n : m)})', SizedBox(height: 160, child: _DailyChart(d.daily))),
      _Card('Top cities', _Bars(d.cities.take(8).toList())),
      _Card('Top hiring companies', _Bars(d.companies.take(8).toList())),
      _Card(
        'In-demand skills (30 days)',
        Column(children: [
          for (final s in d.skills.take(12))
            ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(s.name), trailing: Text('${s.jobs}  ${s.trend == null ? 'new' : '${s.trend! >= 0 ? '▲' : '▼'} ${s.trend!.abs().round()}%'}', style: TextStyle(color: s.trend == null ? null : (s.trend! >= 0 ? Colors.green : Colors.red)))),
        ]),
      ),
    ]);
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.title, this.value, {this.sub});
  final String title, value;
  final String? sub;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: Theme.of(context).textTheme.bodySmall), Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)), if (sub != null) Text(sub!, style: Theme.of(context).textTheme.labelSmall)])));
}

class _Card extends StatelessWidget {
  const _Card(this.title, this.child);
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleSmall), const SizedBox(height: 10), child])));
}

class _DailyChart extends StatelessWidget {
  const _DailyChart(this.daily);
  final List<({String day, int n})> daily;
  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const EmptyView('No data');
    final color = Theme.of(context).colorScheme.primary;
    return LineChart(LineChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      minY: 0,
      lineBarsData: [LineChartBarData(spots: [for (var i = 0; i < daily.length; i++) FlSpot(i.toDouble(), daily[i].n.toDouble())], isCurved: true, color: color, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: color.withValues(alpha: .15)))],
    ));
  }
}

class _Bars extends StatelessWidget {
  const _Bars(this.items);
  final List<NamedCount> items;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('No data');
    final max = items.first.jobs.toDouble();
    return Column(children: [
      for (final i in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            SizedBox(width: 110, child: Text(i.name, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: max == 0 ? 0 : i.jobs / max, minHeight: 10))),
            SizedBox(width: 40, child: Text('${i.jobs}', textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodySmall)),
          ]),
        ),
    ]);
  }
}
