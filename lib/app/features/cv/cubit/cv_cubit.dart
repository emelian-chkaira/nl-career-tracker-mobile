import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart' show RequestOptions;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/errors/custom_errors.dart';
import '../../../../core/base_states/base_states.dart';
import '../repo/cv_repo.dart';

class CvState extends FeatureState {
  final Map<String, dynamic>? cv;
  final String latex, tailoredText, letter, fileName, pdfEngine, mode;
  final List<String> matched, gaps;
  final int score;
  final Uint8List? pdf;
  final bool dirty, consent, localOk, aiOk, aiConsent;
  final List<Map<String, dynamic>> aiChanges;
  final Map<String, dynamic>? aiResult;
  const CvState({super.status, super.error, this.cv, this.latex = '', this.tailoredText = '', this.letter = '', this.fileName = '', this.matched = const [], this.gaps = const [], this.score = 0, this.pdf, this.pdfEngine = '', this.mode = 'local', this.dirty = false, this.consent = false, this.localOk = true, this.aiOk = false, this.aiConsent = false, this.aiChanges = const [], this.aiResult});
  CvState copy({Status? status, error, Map<String, dynamic>? cv, String? latex, String? tailoredText, String? letter, String? fileName, List<String>? matched, List<String>? gaps, int? score, Uint8List? pdf, bool clearPdf = false, String? pdfEngine, String? mode, bool? dirty, bool? consent, bool? localOk, bool? aiOk, bool? aiConsent, List<Map<String, dynamic>>? aiChanges, Map<String, dynamic>? aiResult, bool clearAi = false}) => CvState(
      status: status ?? this.status, error: error, cv: cv ?? this.cv, latex: latex ?? this.latex, tailoredText: tailoredText ?? this.tailoredText, letter: letter ?? this.letter, fileName: fileName ?? this.fileName,
      matched: matched ?? this.matched, gaps: gaps ?? this.gaps, score: score ?? this.score, pdf: clearPdf ? null : (pdf ?? this.pdf), pdfEngine: pdfEngine ?? this.pdfEngine, mode: mode ?? this.mode, dirty: dirty ?? this.dirty, consent: consent ?? this.consent, localOk: localOk ?? this.localOk, aiOk: aiOk ?? this.aiOk, aiConsent: aiConsent ?? this.aiConsent, aiChanges: clearAi ? const [] : (aiChanges ?? this.aiChanges), aiResult: clearAi ? null : (aiResult ?? this.aiResult));
  @override
  List<Object?> get props => [...super.props, cv, latex, tailoredText, letter, fileName, matched, gaps, score, pdf, pdfEngine, mode, dirty, consent, localOk, aiOk, aiConsent, aiChanges, aiResult];
}

/// Stateless on the server: the imported CV only lives in this cubit.
class CvCubit extends Cubit<CvState> {
  CvCubit({required this.repo}) : super(const CvState(status: Status.loaded));
  final CvRepo repo;

  Future<void> init() async {
    try {
      final c = await repo.compilers();
      emit(state.copy(status: state.status, localOk: c['local'] == true, aiOk: c['ai'] == true, mode: c['local'] == true ? state.mode : 'public'));
    } on CustomDioException {/* keep defaults */}
  }

  Future<void> upload(List<int> bytes, String name) => _run(() async {
        final r = await repo.extract(bytes, name);
        emit(state.copy(status: Status.loaded, cv: Map<String, dynamic>.from(r['cv'] ?? {}), latex: r['latex'] ?? '', fileName: name, tailoredText: '', letter: '', clearPdf: true, dirty: false));
      });

  void reset() => emit(CvState(status: Status.loaded, localOk: state.localOk, mode: state.localOk ? 'local' : 'public'));

  /// Removes one item from a list field (languages, skills, references, certifications) so a wrong extraction can be fixed.
  void removeItem(String key, int i) {
    final cv = Map<String, dynamic>.from(state.cv ?? {});
    final l = List<dynamic>.from(cv[key] ?? [])..removeAt(i);
    final removed = (state.cv?[key] as List?)?[i];
    cv[key] = l;
    if (key == 'skills' && cv['skill_groups'] is List) {                       // keep the grouped skills table in sync
      cv['skill_groups'] = [
        for (final g in cv['skill_groups'] as List)
          {...Map<String, dynamic>.from(g as Map), 'items': [for (final x in (g['items'] as List)) if (x != removed) x]}
      ].where((g) => (g['items'] as List).isNotEmpty).toList();
    }
    emit(state.copy(status: Status.loaded, cv: cv, dirty: true));
  }

  Future<void> rebuildLatex() => _run(() async {
        final tex = await repo.latex(state.cv!);
        emit(state.copy(status: Status.loaded, latex: tex, dirty: false, clearPdf: true));
      });

  void setMode(String m) => emit(state.copy(status: state.status, mode: m));
  void setAiConsent(bool v) => emit(state.copy(status: state.status, aiConsent: v));
  void discardAi() => emit(state.copy(status: Status.loaded, clearAi: true));
  void applyAi() {
    final r = state.aiResult;
    if (r == null) return;
    emit(state.copy(status: Status.loaded, cv: Map<String, dynamic>.from(r['cv']), latex: r['latex'] as String, clearPdf: true, clearAi: true, dirty: false));
  }

  Future<void> aiTailor(int jobId) => _run(() async {
        final r = await repo.aiTailor(state.cv!, jobId, state.aiConsent);
        emit(state.copy(status: Status.loaded, aiResult: r, aiChanges: ((r['changes'] as List?) ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList(), gaps: ((r['gaps'] as List?) ?? []).map((e) => e.toString()).toList()));
      });

  void setConsent(bool v) => emit(state.copy(status: state.status, consent: v));

  Future<void> buildPdf() => _run(() async {
        if (state.mode == 'public' && !state.consent) throw CustomDioException(RequestOptions(), null, ErrorType.badRequest, 'Tick the consent box to use a public LaTeX service.');
        final r = await repo.pdf(state.latex, mode: state.mode, consent: state.consent);
        emit(state.copy(status: Status.loaded, pdf: base64Decode(r['pdf_b64'] as String), pdfEngine: '${r['engine']}'));
      });

  Future<void> tailor(int jobId) => _run(() async {
        final r = await repo.tailor(state.cv!, state.latex, jobId);
        emit(state.copy(status: Status.loaded, tailoredText: r['text'] ?? '', score: (r['match_score'] as num?)?.toInt() ?? 0,
            matched: ((r['matched'] as List?) ?? []).map((e) => e.toString()).toList(), gaps: ((r['gaps'] as List?) ?? []).map((e) => e.toString()).toList(),
            latex: (r['latex'] as String?)?.isNotEmpty == true ? r['latex'] as String : state.latex, clearPdf: true));
      });

  Future<void> letter(int jobId) => _run(() async => emit(state.copy(status: Status.loaded, letter: await repo.coverLetter(state.cv!, jobId))));

  Future<void> _run(Future<void> Function() op) async {
    emit(state.copy(status: Status.loading));
    try {
      await op();
    } on CustomDioException catch (e) {
      emit(state.copy(status: Status.failed, error: e));
    }
  }
}
