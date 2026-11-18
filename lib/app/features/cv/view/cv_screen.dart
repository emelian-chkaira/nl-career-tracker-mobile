import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/base_states/base_states.dart';
import '../../../../core/styles/style.dart';
import '../../../global/widgets/widgets.dart';
import '../cubit/cv_cubit.dart';

class CvScreen extends StatefulWidget {
  const CvScreen({super.key, this.jobId});
  final int? jobId;
  @override
  State<CvScreen> createState() => _CvScreenState();
}

class _CvScreenState extends State<CvScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CvCubit>().init();
  }

  Future<void> _pick(BuildContext context) async {
    final r = await FilePicker.platform.pickFiles(withData: true, type: FileType.custom, allowedExtensions: ['pdf', 'docx', 'txt', 'tex', 'md']);
    final f = r?.files.single;
    if (f?.bytes == null || !context.mounted) return;
    context.read<CvCubit>().upload(f!.bytes!, f.name);
  }

  Future<void> _sharePdf(CvState s) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${(s.cv?['name'] ?? 'cv').toString().replaceAll(' ', '_')}_CV.pdf');
    await file.writeAsBytes(s.pdf!);
    await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf')]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('CV Studio')),
        body: BlocConsumer<CvCubit, CvState>(
          listener: (context, s) {
            if (s.status == Status.failed) showSnack(context, s.error?.message ?? 'Failed');
          },
          builder: (context, s) {
            final busy = s.status == Status.loading;
            final cubit = context.read<CvCubit>();
            final cv = s.cv;
            return ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 24), children: [
              if (cv == null)
                HeroBanner(
                  title: 'Import your CV, export a clean PDF',
                  subtitle: 'PDF, DOCX, LaTeX or text. Links and layout are kept; nothing is stored on the server.',
                  child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kBrand), icon: const Icon(Icons.upload_file), label: Text(busy ? 'Reading…' : 'Choose CV file'), onPressed: busy ? null : () => _pick(context)),
                ),
              if (busy) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator()),
              if (cv != null) ...[
                Section('Extracted from ${s.fileName}', trailing: TextButton(onPressed: cubit.reset, child: const Text('Replace')), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _kv('Name', cv['name']),
                  _kv('Email', cv['email']),
                  _kv('Phone', cv['phone']),
                  _kv('Location', cv['location']),
                  _chips(context, 'Languages', 'languages', cv['languages'], cubit),
                  _chips(context, 'References', 'references', cv['references'], cubit),
                  _chips(context, 'Skills', 'skills', cv['skills'], cubit, max: 14),
                  if (s.dirty) Padding(padding: const EdgeInsets.only(top: 8), child: FilledButton.tonal(onPressed: busy ? null : cubit.rebuildLatex, child: const Text('Apply edits → LaTeX'))),
                ])),
                const SizedBox(height: 10),
                Section('PDF export', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SegmentedButton<String>(
                    segments: [ButtonSegment(value: 'local', label: const Text('This server'), enabled: s.localOk), const ButtonSegment(value: 'public', label: Text('Public LaTeX'))],
                    selected: {s.mode},
                    onSelectionChanged: (v) => cubit.setMode(v.first),
                  ),
                  if (s.mode == 'public')
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: s.consent,
                      onChanged: (v) => cubit.setConsent(v ?? false),
                      title: const Text('Send this CV to a third-party compiler (latex.ytotech.com, then texlive.net). It contains personal data and leaves our server.', style: TextStyle(fontSize: 12.5)),
                    ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: FilledButton.icon(icon: const Icon(Icons.picture_as_pdf_outlined), label: Text(busy ? 'Compiling…' : 'Build PDF'), onPressed: busy || (s.mode == 'public' && !s.consent) ? null : cubit.buildPdf)),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () { Clipboard.setData(ClipboardData(text: s.latex)); showSnack(context, 'LaTeX copied. Paste it into Overleaf.'); }, child: const Text('Copy .tex')),
                  ]),
                  if (s.pdf != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: Text('Built with ${s.pdfEngine} · ${(s.pdf!.length / 1024).round()} KB', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                      FilledButton.tonalIcon(onPressed: () => _sharePdf(s), icon: const Icon(Icons.ios_share, size: 18), label: const Text('Open / share')),
                    ]),
                  ],
                ])),
                const SizedBox(height: 10),
                Section('Tailor to a job', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (widget.jobId == null)
                    const Text('Open a job and tap “Tailor CV” to pick the target role.')
                  else
                    Row(children: [
                      Expanded(child: FilledButton(onPressed: busy ? null : () => cubit.tailor(widget.jobId!), child: const Text('Tailor CV'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton(onPressed: busy ? null : () => cubit.letter(widget.jobId!), child: const Text('Cover letter'))),
                    ]),
                  if (s.tailoredText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Match ${s.score}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 6, children: [for (final m in s.matched) Pill(m, color: Colors.green), for (final g in s.gaps.take(8)) Pill('gap: $g', outlined: true)]),
                    const SizedBox(height: 6),
                    const Text('Tailoring only re-orders what is already in your CV. Build the PDF above to get the tailored version.', style: TextStyle(fontSize: 12)),
                  ],
                ])),
                const SizedBox(height: 10),
                Section('AI tailoring', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (!s.aiOk)
                    const Text('Not enabled on this server. Set ANTHROPIC_API_KEY to let Claude rewrite your CV for a job. It only rewords what your CV already says.', style: TextStyle(fontSize: 12.5))
                  else ...[
                    const Text('Claude rewrites the summary and bullets for the posting and lists gaps. You review every change first.', style: TextStyle(fontSize: 12.5)),
                    CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, value: s.aiConsent, onChanged: (v) => cubit.setAiConsent(v ?? false), title: const Text('Send my CV and this posting to Anthropic. It contains personal data.', style: TextStyle(fontSize: 12.5))),
                    FilledButton.icon(icon: const Icon(Icons.auto_awesome), label: Text(busy ? 'Claude is tailoring…' : 'Tailor with AI'), onPressed: busy || widget.jobId == null || !s.aiConsent ? null : () => cubit.aiTailor(widget.jobId!)),
                    if (widget.jobId == null) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Open a job and tap “Tailor CV” first.', style: TextStyle(fontSize: 12))),
                  ],
                  for (final c in s.aiChanges)
                    Padding(padding: const EdgeInsets.only(top: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${c['section']}${(c['title'] ?? '').toString().isEmpty ? '' : ' · ${c['title']}'}', style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      Text('${c['before'] ?? ''}', style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                      Text('${c['after'] ?? ''}', style: const TextStyle(fontSize: 12.5)),
                    ])),
                  if (s.aiResult != null) Padding(padding: const EdgeInsets.only(top: 12), child: Row(children: [
                    Expanded(child: FilledButton(onPressed: cubit.applyAi, child: Text('Apply ${s.aiChanges.length} changes'))),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: cubit.discardAi, child: const Text('Discard')),
                  ])),
                ])),
                if (s.letter.isNotEmpty) ...[const SizedBox(height: 10), _Output('Cover letter', s.letter)],
              ],
            ]);
          },
        ),
      );

  Widget _kv(String k, dynamic v) => (v == null || '$v'.isEmpty)
      ? const SizedBox.shrink()
      : Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 72, child: Text(k, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))), Expanded(child: Text('$v', style: const TextStyle(fontWeight: FontWeight.w600)))]));

  Widget _chips(BuildContext context, String title, String key, dynamic list, CvCubit cubit, {int max = 99}) {
    final items = ((list as List?) ?? []).map((e) => e.toString().replaceAllMapped(RegExp(r'\[([^\]]+)\]\(([^)]+)\)'), (m) => m[1]!)).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Wrap(spacing: 6, runSpacing: 4, children: [for (var i = 0; i < items.length && i < max; i++) InputChip(label: Text(items[i], style: const TextStyle(fontSize: 12)), visualDensity: VisualDensity.compact, onDeleted: () => cubit.removeItem(key, i))]),
      ]),
    );
  }
}

class _Output extends StatelessWidget {
  const _Output(this.title, this.text);
  final String title, text;
  @override
  Widget build(BuildContext context) => Section(title, trailing: IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () { Clipboard.setData(ClipboardData(text: text)); showSnack(context, 'Copied'); }), child: SelectableText(text));
}
