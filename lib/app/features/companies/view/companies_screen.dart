import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../global/widgets/widgets.dart';
import '../../jobs/view/job_tile.dart';
import '../cubit/companies_cubit.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});
  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final _scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    context.read<CompaniesCubit>().load();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) context.read<CompaniesCubit>().loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Companies')),
        body: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 4), child: TextField(textInputAction: TextInputAction.search, onSubmitted: context.read<CompaniesCubit>().load, decoration: const InputDecoration(hintText: 'Search companies', prefixIcon: Icon(Icons.search)))),
          Expanded(
            child: BlocBuilder<CompaniesCubit, CompaniesState>(
              builder: (context, s) => StatusView(
                state: s,
                onRetry: () => context.read<CompaniesCubit>().load(),
                builder: (_) => s.items.isEmpty
                    ? const EmptyView('No companies found')
                    : ListView.builder(
                        controller: _scroll,
                        itemCount: s.items.length,
                        itemBuilder: (_, i) {
                          final c = s.items[i];
                          return ListTile(
                            leading: CompanyLogo(c),
                            title: Text(c.name),
                            subtitle: Text('${c.city ?? 'Netherlands'} · ${c.openJobs} open roles${c.sponsor ? ' · IND sponsor' : ''}'),
                            trailing: c.careersUrl == null ? null : IconButton(icon: const Icon(Icons.open_in_new), onPressed: () => launchUrl(Uri.parse(c.careersUrl!), mode: LaunchMode.externalApplication)),
                          );
                        },
                      ),
              ),
            ),
          ),
        ]),
      );
}
