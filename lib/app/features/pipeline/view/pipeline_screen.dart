import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/format.dart';
import '../../../global/widgets/widgets.dart';
import '../../jobs/view/job_detail_screen.dart' show stages;
import '../../jobs/view/job_tile.dart';
import '../cubit/pipeline_cubit.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PipelineCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.read<PipelineCubit>();
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: const Text('My pipeline')),
      body: BlocBuilder<PipelineCubit, PipelineState>(
        builder: (context, s) => StatusView(
          state: s,
          onRetry: c.load,
          builder: (_) {
            if (s.items.isEmpty) return const EmptyView('Open a job and pick a pipeline stage to start tracking.', icon: Icons.view_kanban_outlined);
            return RefreshIndicator(
              onRefresh: c.load,
              child: ListView(children: [
                for (final st in stages)
                  if (s.items.any((j) => j.stage == st)) ...[
                    Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('${label(st)} (${s.items.where((j) => j.stage == st).length})', style: Theme.of(context).textTheme.titleSmall)),
                    for (final j in s.items.where((j) => j.stage == st))
                      Dismissible(key: ValueKey(j.id), direction: DismissDirection.endToStart, background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)), onDismissed: (_) => c.remove(j.id), child: JobTile(job: j, onTap: () => Navigator.of(context).pushNamed(AppRouter.jobDetail, arguments: j.id).then((_) => c.load()))),
                  ],
              ]),
            );
          },
        ),
      ),
    );
  }
}
