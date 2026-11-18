class NamedCount {
  final String name;
  final int jobs;
  NamedCount(this.name, this.jobs);
}

class SkillTrend {
  final String name;
  final int jobs;
  final double? trend;
  SkillTrend(this.name, this.jobs, this.trend);
}

class Overview {
  final Map<String, num> kpi;
  final List<({String day, int n})> daily;
  final List<NamedCount> cities, companies;
  final List<SkillTrend> skills;
  Overview({required this.kpi, required this.daily, required this.cities, required this.companies, required this.skills});

  factory Overview.fromJson(Map<String, dynamic> j) {
    List<NamedCount> named(String k) => ((j[k] as List?) ?? []).map((e) => NamedCount(e['name'].toString(), e['jobs'] as int)).toList();
    return Overview(
      kpi: {for (final e in (j['kpi'] as Map).entries) e.key.toString(): (e.value as num?) ?? 0},
      daily: ((j['daily'] as List?) ?? []).map((e) => (day: e['day'].toString(), n: (e['new_jobs'] as num).toInt())).toList(),
      cities: named('cities'),
      companies: named('companies'),
      skills: ((j['skills'] as List?) ?? []).map((e) => SkillTrend(e['name'].toString(), (e['last_30d'] ?? e['jobs']) as int, (e['trend'] as num?)?.toDouble())).toList(),
    );
  }
}
