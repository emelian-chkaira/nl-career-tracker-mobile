import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/features/alerts/cubit/alerts_cubit.dart';
import 'app/features/my/view/my_search_screen.dart';
import 'app/features/auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import 'app/features/dashboard/cubit/dashboard_cubit.dart';
import 'app/features/dashboard/view/dashboard_screen.dart';
import 'app/features/jobs/cubit/jobs_cubit.dart';
import 'app/features/jobs/models/job_model.dart';
import 'app/features/jobs/view/jobs_screen.dart';
import 'app/features/profile/cubit/profile_cubit.dart';
import 'app/features/profile/view/profile_screen.dart';
import 'core/utils/dependencies.dart';

/// Splash while the session restores, then the tabbed home. Guests can browse; account features prompt for sign-in.
class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<AppWrapperCubit, AppWrapperState>(
        builder: (context, s) => s.userState == UserState.unknown ? const Scaffold(body: Center(child: CircularProgressIndicator())) : HomeShell(key: ValueKey(s.user?.id ?? 'guest')),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<JobsCubit>(param1: null)),
          BlocProvider(create: (_) => getIt<DashboardCubit>()),
          BlocProvider(create: (_) => getIt<AlertsCubit>()),
          BlocProvider(create: (_) => getIt<ProfileCubit>()),
        ],
        child: Scaffold(
          body: IndexedStack(index: _i, children: [
            _JobsTab(),
            DashboardScreen(),
            MySearchScreen(),
            ProfileScreen(),
          ].asMap().entries.map((e) => _TabHost(index: e.key, current: _i, child: e.value)).toList()),
          bottomNavigationBar: NavigationBar(selectedIndex: _i, onDestinationSelected: (v) => setState(() => _i = v), destinations: const [
            NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
            NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Market'),
            NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'My search'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Me'),
          ]),
        ),
      );
}

/// Builds a tab's content the first time it is shown, then keeps it alive.
class _TabHost extends StatefulWidget {
  const _TabHost({required this.index, required this.current, required this.child});
  final int index, current;
  final Widget child;
  @override
  State<_TabHost> createState() => _TabHostState();
}

class _TabHostState extends State<_TabHost> {
  bool _built = false;
  @override
  Widget build(BuildContext context) {
    _built = _built || widget.index == widget.current;
    return _built ? widget.child : const SizedBox.shrink();
  }
}

/// Jobs and internships share one tab with a switch on top; each keeps its own search state.
class _JobsTab extends StatefulWidget {
  const _JobsTab();
  @override
  State<_JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<_JobsTab> {
  bool _intern = false;
  @override
  Widget build(BuildContext context) => Column(children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(width: double.infinity, child: SegmentedButton<bool>(showSelectedIcon: false, segments: const [ButtonSegment(value: false, label: Text('Jobs')), ButtonSegment(value: true, label: Text('Internships'))], selected: {_intern}, onSelectionChanged: (v) => setState(() => _intern = v.first))),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: IndexedStack(index: _intern ? 1 : 0, children: [
              const JobsScreen(title: 'Tech jobs in NL'),
              BlocProvider(create: (_) => getIt<JobsCubit>(param1: const JobFilters(kind: 'internship')), child: const JobsScreen(title: 'Internships')),
            ]),
          ),
        ),
      ]);
}
