import 'package:flutter/material.dart';

import '../../../core/api/errors/custom_errors.dart';
import '../../../core/base_states/base_states.dart';

class TryAgain extends StatelessWidget {
  const TryAgain({super.key, required this.error, required this.onRetry});
  final CustomDioException? error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(error?.errorType == ErrorType.noInternet ? Icons.wifi_off : Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 8),
            Text(error?.message ?? 'Something went wrong', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Try again')),
          ]),
        ),
      );
}

class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
}

class EmptyView extends StatelessWidget {
  const EmptyView(this.text, {super.key, this.icon = Icons.inbox_outlined});
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 40, color: Theme.of(context).colorScheme.outline), const SizedBox(height: 8), Text(text, textAlign: TextAlign.center)]),
        ),
      );
}

/// Renders loading / failed / content for any FeatureState.
class StatusView extends StatelessWidget {
  const StatusView({super.key, required this.state, required this.onRetry, required this.builder});
  final FeatureState state;
  final VoidCallback onRetry;
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) => switch (state.status) {
        Status.initial || Status.loading => const Loading(),
        Status.failed => TryAgain(error: state.error, onRetry: onRetry),
        Status.loaded => builder(context),
      };
}

void showSnack(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

class SignInPrompt extends StatelessWidget {
  const SignInPrompt({super.key, required this.what});
  final String what;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_outline, size: 40),
            const SizedBox(height: 8),
            Text('Sign in to $what', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => Navigator.of(context).pushNamed('/login'), child: const Text('Sign in')),
          ]),
        ),
      );
}

/// Small rounded label used for job type, sponsor flag, skills, etc.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color, this.outlined = false});
  final String text;
  final Color? color;
  final bool outlined;
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(color: outlined ? null : c.withValues(alpha: .12), border: outlined ? Border.all(color: Theme.of(context).dividerColor) : null, borderRadius: BorderRadius.circular(99)),
      child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: outlined ? muted : c)),
    );
  }
}

/// Section card with a small uppercase heading (mirrors the web "card" + h3).
class Section extends StatelessWidget {
  const Section(this.title, {super.key, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, letterSpacing: .8, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant))), if (trailing != null) trailing!]),
            const SizedBox(height: 10),
            child,
          ]),
        ),
      );
}
