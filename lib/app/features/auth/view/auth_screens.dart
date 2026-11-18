import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/base_states/base_states.dart';
import '../../../../core/styles/style.dart';
import '../../../global/widgets/widgets.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.register});
  final bool register;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _pass = TextEditingController(), _name = TextEditingController();
  bool _show = false, _agree = false;
  late final Future<String?> _googleId = context.read<AuthCubit>().googleClientId();

  int get _strength {
    final p = _pass.text;
    var n = 0;
    if (p.length >= 8) n++;
    if (p.length >= 12) n++;
    if (RegExp('[a-z]').hasMatch(p) && RegExp('[A-Z]').hasMatch(p)) n++;
    if (RegExp(r'\d').hasMatch(p) && RegExp('[^A-Za-z0-9]').hasMatch(p)) n++;
    return n;
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    if (widget.register && !_agree) { showSnack(context, 'Please confirm the storage note to continue.'); return; }
    final c = context.read<AuthCubit>();
    widget.register ? c.register(_email.text, _pass.text, _name.text) : c.login(_email.text, _pass.text);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.register;
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, s) {
          if (s.status == Status.loaded) Navigator.of(context).popUntil((route) => route.isFirst);
        },
        builder: (context, s) => SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 24), children: [
            HeroBanner(title: r ? 'Create your account' : 'Welcome back', subtitle: r ? 'Free. Save searches, get job alerts and track your applications.' : 'Sign in to your saved searches, alerts and pipeline.'),
            const SizedBox(height: 12),
            FutureBuilder<String?>(
              future: _googleId,
              builder: (context, snap) => snap.data == null ? const SizedBox.shrink() : Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                child: Column(children: [
                  OutlinedButton.icon(
                    onPressed: s.status == Status.loading ? null : () => context.read<AuthCubit>().google(snap.data!),
                    icon: const Icon(Icons.g_mobiledata, size: 30),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
                  const SizedBox(height: 8),
                  Text('or use your email', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Form(
                key: _form,
                child: Column(children: [
                  if (r) ...[TextFormField(controller: _name, autofillHints: const [AutofillHints.name], decoration: const InputDecoration(labelText: 'Name')), const SizedBox(height: 12)],
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: const InputDecoration(labelText: 'Email'), validator: (v) => RegExp(r'^\S+@\S+\.\S+$').hasMatch(v ?? '') ? null : 'Enter a valid email'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pass,
                    obscureText: !_show,
                    onChanged: (_) => setState(() {}),
                    autofillHints: [r ? AutofillHints.newPassword : AutofillHints.password],
                    decoration: InputDecoration(labelText: 'Password', suffixIcon: IconButton(icon: Icon(_show ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _show = !_show))),
                    validator: (v) => (v ?? '').length >= (r ? 8 : 1) ? null : (r ? 'At least 8 characters' : 'Enter your password'),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (r && _pass.text.isNotEmpty) Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(children: [
                      for (var i = 1; i <= 4; i++) Expanded(child: Container(height: 5, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: i <= _strength ? (_strength <= 1 ? Colors.red : _strength == 2 ? Colors.orange : Colors.green) : Theme.of(context).dividerColor))),
                      Text(const ['Too short', 'Weak', 'Okay', 'Good', 'Strong'][_strength], style: const TextStyle(fontSize: 12)),
                    ]),
                  ),
                  if (r) CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, value: _agree, onChanged: (v) => setState(() => _agree = v ?? false), title: const Text('I understand my saved searches and tracked jobs are stored on this server, and that my CV is never stored.', style: TextStyle(fontSize: 12.5))),
                ]),
              ),
            ),
            if (s.status == Status.failed) Padding(padding: const EdgeInsets.only(top: 12), child: Text(s.error?.message ?? 'Failed', style: TextStyle(color: Theme.of(context).colorScheme.error))),
            if (!r) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).pushNamed('/forgot'), child: const Text('Forgot password?'))),
            const SizedBox(height: 8),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: FilledButton(onPressed: s.status == Status.loading ? null : _submit, child: Text(s.status == Status.loading ? 'Please wait…' : (r ? 'Create account' : 'Sign in')))),
            TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed(r ? '/login' : '/register'), child: Text(r ? 'I already have an account' : 'Create an account')),
            TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('Continue without an account')),
          ]),
        ),
      ),
    );
  }
}
