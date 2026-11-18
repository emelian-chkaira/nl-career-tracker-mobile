String label(String s) => s.isEmpty ? s : s.replaceAll('_', ' ').replaceRange(0, 1, s[0].toUpperCase());

String ago(String? iso) {
  if (iso == null) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  final days = DateTime.now().difference(d).inDays;
  if (days <= 0) return 'today';
  if (days == 1) return 'yesterday';
  if (days < 31) return '${days}d ago';
  if (days < 365) return '${days ~/ 30}mo ago';
  return '${days ~/ 365}y ago';
}

String stripMarks(String? html) => (html ?? '').replaceAll(RegExp(r'<[^>]*>'), '');
