import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/dependencies.dart';
import '../../alerts/view/alerts_screen.dart';
import '../../inbox/cubit/inbox_cubit.dart';
import '../../inbox/view/inbox_screen.dart';
import '../../pipeline/cubit/pipeline_cubit.dart';
import '../../pipeline/view/pipeline_screen.dart';

/// "My search": pipeline, alerts and inbox in one tab instead of three.
class MySearchScreen extends StatelessWidget {
  const MySearchScreen({super.key});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [BlocProvider(create: (_) => getIt<PipelineCubit>()), BlocProvider(create: (_) => getIt<InboxCubit>())],
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(title: const Text('My search'), bottom: const TabBar(tabs: [Tab(text: 'Pipeline'), Tab(text: 'Alerts'), Tab(text: 'Inbox')])),
            body: const TabBarView(children: [PipelineScreen(embedded: true), AlertsScreen(embedded: true), InboxScreen()]),
          ),
        ),
      );
}
