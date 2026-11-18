import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/base_states/base_states.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/styles/style.dart';
import '../../../global/widgets/widgets.dart';
import '../cubit/account_cubit.dart';

enum AccountMode { forgot, reset, verify }

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.mode});
  final AccountMode mode;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _link = TextEditingController(), _pass = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _email.dispose();
    _link.dispose();
    _pass.dispose();
    super.dispose();
  }

  (String, String) get _text => switch (widget.mode) {
        AccountMode.forgot => ('Forgot your password?', 'Enter your email and we will send you a reset link.'),
        AccountMode.reset => ('Choose a new password', 'Paste the link from the email (or just its code), then pick a new password.'),
        AccountMode.verify => ('Confirm your email', 'Paste the confirmation link from the email we sent you.'),
      };

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final c = context.read<AccountCubit>();
    switch (widget.mode) {
      case AccountMode.forgot: c.forgot(_email.text);
      case AccountMode.reset: c.reset(_link.text, _pass.text);
      case AccountMode.verify: c.verify(_link.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, sub) = _text;
    final m = widget.mode;
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AccountCubit, AccountState>(
        listener: (context, s) {
          if (s.status != Status.loaded) return;
          if (m == AccountMode.forgot) {
            showSnack(context, 'If an account exists, a reset link is on its way.');
            Navigator.of(context).pushReplacementNamed(AppRouter.reset);
          } else {
            showSnack(context, m == AccountMode.reset ? 'Password updated. Sign in with your new password.' : 'Email confirmed. Thank you!');
            Navigator.of(context).popUntil((r) => r.isFirst);
            if (m == AccountMode.reset) Navigator.of(context).pushNamed(AppRouter.login);
          }
        },
        builder: (context, s) => SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 24), children: [
            HeroBanner(title: title, subtitle: sub),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Form(
                key: _form,
                child: Column(children: [
                  if (m == AccountMode.forgot) TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: const InputDecoration(labelText: 'Email'), validator: (v) => RegExp(r'^\S+@\S+\.\S+$').hasMatch(v ?? '') ? null : 'Enter a valid email'),
                  if (m != AccountMode.forgot) TextFormField(controller: _link, minLines: 1, maxLines: 3, decoration: const InputDecoration(labelText: 'Link or code from the email'), validator: (v) => AccountCubit.tokenFrom(v ?? '').length >= 20 ? null : 'Paste the link from the email'),
                  if (m == AccountMode.reset) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass,
                      obscureText: !_show,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(labelText: 'New password', suffixIcon: IconButton(icon: Icon(_show ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _show = !_show))),
                      validator: (v) => (v ?? '').length >= 8 ? null : 'At least 8 characters',
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ]),
              ),
            ),
            if (s.status == Status.failed) Padding(padding: const EdgeInsets.only(top: 12, left: 6), child: Text(s.error?.message ?? 'Failed', style: TextStyle(color: Theme.of(context).colorScheme.error))),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: FilledButton(onPressed: s.status == Status.loading ? null : _submit, child: Text(s.status == Status.loading ? 'Please wait…' : switch (m) { AccountMode.forgot => 'Send reset link', AccountMode.reset => 'Update password', AccountMode.verify => 'Confirm email' }))),
            if (m == AccountMode.forgot) TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed(AppRouter.reset), child: const Text('I already have a link')),
          ]),
        ),
      ),
    );
  }
}
