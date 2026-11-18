import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/base_states/base_states.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/dependencies.dart';
import '../../auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import '../../auth/repo/auth_repo.dart';
import '../../../global/widgets/widgets.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppWrapperCubit>().state;
    if (s.userState != UserState.authenticated) return Scaffold(appBar: AppBar(title: const Text('Me')), body: const SignInPrompt(what: 'manage your profile'));
    return Scaffold(appBar: AppBar(title: const Text('Me')), body: _Form(key: ValueKey(s.user!.id)));
  }
}

class _Form extends StatefulWidget {
  const _Form({super.key});
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final _skills = TextEditingController(), _titles = TextEditingController(), _cities = TextEditingController();
  bool _english = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AppWrapperCubit>().state.user!;
    _skills.text = u.listOf('skills').join(', ');
    _titles.text = u.listOf('titles').join(', ');
    _cities.text = u.listOf('cities').join(', ');
    _english = u.profile['english_only'] == true;
  }

  List<String> _csv(TextEditingController c) => c.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppWrapperCubit>().state.user!;
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, s) {
        if (s.status == Status.loaded) showSnack(context, s.message ?? 'Saved');
        if (s.status == Status.failed) showSnack(context, s.error?.message ?? 'Failed');
      },
      builder: (context, s) => ListView(padding: const EdgeInsets.all(16), children: [
        ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(user.name.isEmpty ? user.email : user.name), subtitle: Text('${user.email}${user.isAdmin ? ' · admin' : ''}')),
        if (!user.emailVerified) Card(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Confirm your email to secure your account and receive alerts.'),
            Row(children: [
              TextButton(onPressed: () async { await getIt<AuthRepo>().resendVerification().then((_) { if (context.mounted) showSnack(context, 'Confirmation email sent'); }).catchError((_) { if (context.mounted) showSnack(context, 'Could not send the email'); }); }, child: const Text('Resend email')),
              TextButton(onPressed: () => Navigator.of(context).pushNamed(AppRouter.verify), child: const Text('I have the link')),
            ]),
          ])),
        ),
        const SizedBox(height: 8),
        TextField(controller: _skills, decoration: const InputDecoration(labelText: 'Skills (comma separated)', hintText: 'flutter, dart, python')),
        const SizedBox(height: 12),
        TextField(controller: _titles, decoration: const InputDecoration(labelText: 'Target titles')),
        const SizedBox(height: 12),
        TextField(controller: _cities, decoration: const InputDecoration(labelText: 'Preferred cities')),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('English-only roles'), value: _english, onChanged: (v) => setState(() => _english = v)),
        FilledButton(onPressed: s.status == Status.loading ? null : () => context.read<ProfileCubit>().save(skills: _csv(_skills), titles: _csv(_titles), cities: _csv(_cities), englishOnly: _english), child: const Text('Save profile')),
        const Divider(height: 32),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.apartment), title: const Text('Companies'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).pushNamed(AppRouter.companies)),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.view_kanban_outlined), title: const Text('My pipeline'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).pushNamed(AppRouter.pipeline)),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.description_outlined), title: const Text('CV & cover letter'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).pushNamed(AppRouter.cv)),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: () => context.read<AppWrapperCubit>().signOut()),
      ]),
    );
  }
}
